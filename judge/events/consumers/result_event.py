"""Consumer handler for result events.

This handler stores incoming result events as `ResultEvent` model instances so
the submission detail view can read persisted rubrics and score summaries.
Only a minimal set of fields are saved here (enough to show rubrics and
summary scores). The handler ACKs the message on success, and rejects on
error.
"""
import logging
from django.utils import timezone

from judge.events import schemas as event_schemas
from judge.models import ResultEvent

logger = logging.getLogger('judge.events.consumers.result_event')


def handle_event(envelope: dict, message=None):
    channel = envelope.get('channel')
    payload = envelope.get('message') or {}
    logger.info('result_event.handle_event channel=%s id=%s', channel, envelope.get('id'))

    # Validate payload if we have a schema.
    schema = event_schemas.get_schema_for_channel(channel)
    if schema is not None:
        try:
            event_schemas.validate_payload(channel, payload)
        except Exception:
            logger.exception('Result event payload validation failed')
            # Let caller decide; reject the message to surface the problem.
            if message is not None:
                try:
                    message.reject()
                except Exception:
                    logger.exception('Failed to reject message')
            return False

    # Extract the fields we want to persist. Use safe fallbacks when keys are
    # missing; ResultEvent fields are permissive (null=True).
    try:
        event_id = payload.get('evaluation_id') or envelope.get('id')
        event_type = channel
        # Prefer explicit timestamps from the payload; fall back to now.
        event_time = None
        for key in ('started_at', 'created_at', 'event_time'):
            if payload.get(key):
                event_time = payload.get(key)
                break
        if event_time is None:
            event_time = timezone.now()

        source = payload.get('source') or payload.get('origin') or 'evaluator'
        submission_id = str(payload.get('submission_id') or payload.get('submission') or '')
        problem_id = str(payload.get('problem_id') or payload.get('problem') or '')
        status = payload.get('status')
        evaluated_at = payload.get('completed_at') or payload.get('evaluated_at')
        execution_status = payload.get('execution_status') or payload.get('execution')
        timed_out = payload.get('timed_out')

        total_score = payload.get('total_score') or payload.get('score') or payload.get('result_score')
        max_score = payload.get('max_score') or payload.get('max')
        percentage = payload.get('percentage')

        rubrics = payload.get('rubrics')
        metadata = payload.get('metadata') or payload.get('meta')
        artifacts = payload.get('artifacts') or payload.get('containers')

        # Create the ResultEvent record. This is intentionally forgiving —
        # missing fields are stored as null.
        evt = ResultEvent(
            event_id=event_id or '',
            event_type=event_type or '',
            event_time=event_time,
            source=source,
            submission_id=submission_id,
            problem_id=problem_id,
            status=status or '',
            evaluated_at=evaluated_at,
            execution_status=execution_status,
            timed_out=timed_out,
            total_score=total_score,
            max_score=max_score,
            percentage=percentage,
            rubrics=rubrics,
            metadata=metadata,
            artifacts=artifacts,
        )
        evt.save()
        logger.info('Stored ResultEvent id=%s submission=%s', evt.id, submission_id)

        if message is not None:
            try:
                message.ack()
            except Exception:
                logger.exception('Failed to ack message')
        return True
    except Exception:
        logger.exception('Failed to persist ResultEvent')
        if message is not None:
            try:
                message.reject()
            except Exception:
                logger.exception('Failed to reject message after persist failure')
        return False
