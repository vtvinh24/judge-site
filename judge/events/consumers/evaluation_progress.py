"""Consumer handler skeleton for evaluation progress events."""
import logging

from judge.events import schemas as event_schemas

logger = logging.getLogger('judge.events.consumers.evaluation_progress')


def handle_event(envelope: dict, message=None):
    channel = envelope.get('channel')
    payload = envelope.get('message')
    logger.info('evaluation_progress.handle_event channel=%s id=%s', channel, envelope.get('id'))
    schema = event_schemas.get_schema_for_channel(channel)
    if schema is not None:
        event_schemas.validate_payload(channel, payload)
    # TODO: implement progress updates handling
    logger.debug('evaluation progress payload: %s', payload)
    return True
