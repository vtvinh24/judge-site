"""Consumer handler for judge result events.

This handler processes judge.result.created events, persists the result data 
to the ResultEvent model, and makes the data available for display in the 
submission detail view with rubrics tables.

The handler expects messages in the DMOJ envelope format:
{
    "id": "event-id",
    "channel": "judge.result.created",
    "message": {
        "submission_id": "...",
        "status": "completed | error | timed_out",
        "started": "datetime string",
        "completed": "datetime string",
        "total_score": 123.45,
        "max_score": 200,
        "rubrics": [{"rubric_id": "...", "score": 9, "max_score": 10}],
        "metadata": {},
        "artifacts": [...]
    }
}
"""
import logging
from datetime import datetime
from django.utils import timezone
from django.db import transaction

from judge.models import ResultEvent
from judge.events.consumer import register_handler

logger = logging.getLogger('judge.events.consumers.result')


def _parse_datetime(dt_str):
    """Parse a datetime string into a timezone-aware datetime object.
    
    Args:
        dt_str: ISO format datetime string or None
        
    Returns:
        Timezone-aware datetime object or None
    """
    if not dt_str:
        return None
    
    try:
        # Try parsing ISO format with timezone
        dt = datetime.fromisoformat(dt_str.replace('Z', '+00:00'))
        # Ensure it's timezone aware
        if timezone.is_naive(dt):
            dt = timezone.make_aware(dt)
        return dt
    except (ValueError, AttributeError) as e:
        logger.warning('Failed to parse datetime "%s": %s', dt_str, e)
        return None


def handle_result_event(envelope: dict, message=None):
    """Handle a judge.result.created event.
    
    This function:
    1. Extracts the event data from the envelope
    2. Creates or updates a ResultEvent model instance
    3. Stores rubrics and other result data for display
    
    Args:
        envelope: The event envelope containing {id, channel, message}
        message: The Kombu message object (for ACK/NACK)
    
    Raises:
        Exception: If the event cannot be processed (will cause message rejection)
    """
    try:
        event_id = envelope.get('id', '')
        channel = envelope.get('channel', '')
        payload = envelope.get('message', {})
        
        if not event_id or not payload:
            logger.error('Invalid envelope: missing id or message')
            raise ValueError('Invalid envelope structure')
        
        logger.info('Processing result event id=%s', event_id)
        logger.debug('Result event payload: %s', payload)
        
        # Extract required fields
        submission_id = payload.get('submission_id')
        if not submission_id:
            logger.error('Missing submission_id in result event')
            raise ValueError('Missing submission_id')
        
        # Extract optional fields
        problem_id = payload.get('problem_id', '')
        status = payload.get('status', '')
        execution_status = payload.get('execution_status')
        timed_out = payload.get('timed_out')
        
        # Parse datetime fields
        evaluated_at = _parse_datetime(payload.get('completed') or payload.get('evaluated_at'))
        
        # Extract scoring fields
        total_score = payload.get('total_score')
        max_score = payload.get('max_score')
        percentage = payload.get('percentage')
        
        # If percentage not provided, calculate it
        if percentage is None and total_score is not None and max_score is not None and max_score > 0:
            percentage = (total_score / max_score) * 100
        
        # Extract JSON fields
        rubrics = payload.get('rubrics', [])
        metadata = payload.get('metadata', {})
        artifacts = payload.get('artifacts', [])
        
        # Normalize rubrics to ensure they have the expected structure
        normalized_rubrics = []
        for rubric in rubrics:
            if isinstance(rubric, dict):
                normalized_rubric = {
                    'rubric_id': rubric.get('rubric_id', rubric.get('id', '')),
                    'rubric_name': rubric.get('rubric_name', rubric.get('name', '')),
                    'score': rubric.get('score'),
                    'max_score': rubric.get('max_score'),
                    'description': rubric.get('description'),
                }
                # Remove None values to keep JSON clean
                normalized_rubric = {k: v for k, v in normalized_rubric.items() if v is not None}
                normalized_rubrics.append(normalized_rubric)
            else:
                logger.warning('Skipping invalid rubric entry: %s', rubric)
        
        # Use database transaction to ensure atomicity
        with transaction.atomic():
            # Check if we already have this event (idempotency check)
            existing = ResultEvent.objects.filter(
                event_id=event_id,
                submission_id=submission_id
            ).first()
            
            if existing:
                logger.info(
                    'Result event already exists: event_id=%s submission_id=%s, updating',
                    event_id, submission_id
                )
                # Update existing record
                existing.event_type = channel
                existing.event_time = timezone.now()
                existing.problem_id = problem_id or existing.problem_id
                existing.status = status or existing.status
                existing.evaluated_at = evaluated_at or existing.evaluated_at
                existing.execution_status = execution_status
                existing.timed_out = timed_out
                existing.total_score = total_score
                existing.max_score = max_score
                existing.percentage = percentage
                existing.rubrics = normalized_rubrics if normalized_rubrics else existing.rubrics
                existing.metadata = metadata if metadata else existing.metadata
                existing.artifacts = artifacts if artifacts else existing.artifacts
                existing.save()
                
                logger.info('Updated ResultEvent id=%s for submission=%s', existing.id, submission_id)
            else:
                # Create new record
                result_event = ResultEvent.objects.create(
                    event_id=event_id,
                    event_type=channel,
                    event_time=timezone.now(),
                    source=payload.get('source', 'judge'),
                    submission_id=submission_id,
                    problem_id=problem_id,
                    status=status,
                    evaluated_at=evaluated_at,
                    execution_status=execution_status,
                    timed_out=timed_out,
                    total_score=total_score,
                    max_score=max_score,
                    percentage=percentage,
                    rubrics=normalized_rubrics if normalized_rubrics else None,
                    metadata=metadata if metadata else None,
                    artifacts=artifacts if artifacts else None,
                )
                
                logger.info('Created ResultEvent id=%s for submission=%s', result_event.id, submission_id)
        
        logger.info('Successfully processed result event for submission=%s', submission_id)
        
    except Exception as e:
        logger.exception('Failed to process result event: %s', e)
        raise


# Register this handler for the judge.result.created routing key
register_handler('judge.result.created', handle_result_event)

logger.info('Registered result event handler for routing key: judge.result.created')
