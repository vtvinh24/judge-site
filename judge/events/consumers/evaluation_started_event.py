"""Consumer handler skeleton for evaluation started events."""
import logging

from judge.events import schemas as event_schemas

logger = logging.getLogger('judge.events.consumers.evaluation_started_event')


def handle_event(envelope: dict, message=None):
    channel = envelope.get('channel')
    payload = envelope.get('message')
    logger.info('evaluation_started_event.handle_event channel=%s id=%s', channel, envelope.get('id'))
    schema = event_schemas.get_schema_for_channel(channel)
    if schema is not None:
        event_schemas.validate_payload(channel, payload)
    # TODO: implement evaluation started handling
    logger.debug('evaluation started payload: %s', payload)
    return True
