"""Consumer handler skeleton for build result events."""
import logging

from judge.events import schemas as event_schemas

logger = logging.getLogger('judge.events.consumers.build_result_event')


def handle_event(envelope: dict, message=None):
    channel = envelope.get('channel')
    payload = envelope.get('message')
    logger.info('build_result_event.handle_event channel=%s id=%s', channel, envelope.get('id'))
    schema = event_schemas.get_schema_for_channel(channel)
    if schema is not None:
        event_schemas.validate_payload(channel, payload)
    # TODO: implement build result handling
    logger.debug('build result payload: %s', payload)
    return True
