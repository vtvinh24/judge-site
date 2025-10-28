"""Consumer handler skeleton for artifact events.

This module provides a small handler entry point `handle_event(envelope, message)`
that other consumers can call. It validates the inner payload (if a schema is
available) and contains a placeholder for further processing.
"""
import logging

from judge.events import schemas as event_schemas

logger = logging.getLogger('judge.events.consumers.artifact_event')


def handle_event(envelope: dict, message=None):
    """Handle an incoming artifact event envelope.

    - envelope: the outer AMQP envelope with keys `id`, `channel`, `message`
    - message: optional kombu message object
    Returns True on success, False on handled/rejection.
    """
    channel = envelope.get('channel')
    payload = envelope.get('message')
    logger.info('artifact_event.handle_event channel=%s id=%s', channel, envelope.get('id'))

    schema = event_schemas.get_schema_for_channel(channel)
    if schema is not None:
        event_schemas.validate_payload(channel, payload)

    # TODO: implement actual handling logic here
    logger.debug('artifact payload: %s', payload)
    return True
