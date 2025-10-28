import time
import logging
import os
from typing import Any

from kombu import Connection, Exchange, Producer
from django.conf import settings

__all__ = ["post", "last", "real"]

logger = logging.getLogger('judge.events.poster')

# Mirror the old behavior: allow disabling via settings.EVENT_DAEMON_USE
real = bool(getattr(settings, 'EVENT_DAEMON_USE', True))


def _get_broker_url():
    return getattr(settings, 'EVENT_DAEMON_AMQP', None) or getattr(settings, 'CELERY_BROKER_URL', None) or os.environ.get('EVENT_DAEMON_AMQP')


def post(channel: str, message: Any) -> int:
    """Publish an envelope {id, channel, message} to the configured topic exchange.

    Returns the event id on success, or 0 on failure/drop.
    """
    if not real:
        logger.debug('Event poster disabled; dropping event channel=%s', channel)
        return 0

    broker = _get_broker_url()
    if not broker:
        logger.warning('No AMQP broker configured; dropping event channel=%s', channel)
        return 0

    exchange_name = getattr(settings, 'EVENT_DAEMON_AMQP_EXCHANGE', 'dmoj-events')
    appid = getattr(settings, 'EVENT_PUBLISHER_APPID', 'judge')

    exchange = Exchange(exchange_name, type='topic', durable=True)
    conn = Connection(broker)

    eid = int(time.time() * 1000000)
    envelope = {'id': eid, 'channel': channel, 'message': message}

    try:
        with conn:
            producer = Producer(conn)
            producer.publish(
                envelope,
                exchange=exchange,
                routing_key=channel,
                serializer='json',
                declare=[exchange],
                retry=True,
                retry_policy={'max_retries': 3},
                headers={'app_id': appid},
                delivery_mode=2,
            )
        logger.info('Published event id=%s channel=%s exchange=%s', eid, channel, exchange_name)
        logger.debug('Published event payload=%s', envelope)
        return eid
    except Exception:
        logger.exception('Failed to publish event channel=%s', channel)
        return 0


def last() -> int:
    return int(time.time() * 1000000)
