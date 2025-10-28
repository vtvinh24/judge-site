"""Heartbeat publisher (moves from top-level heartbeat script).

Publishes a single dummy heartbeat to the configured exchange and routing key.
"""
import json
import os
import time
import uuid
import logging

from kombu import Connection, Exchange, Producer

logger = logging.getLogger('judge.events.publishers.heartbeat')
logging.basicConfig(level=logging.INFO)


def get_config():
    broker = os.environ.get('EVENT_DAEMON_AMQP')
    exchange = os.environ.get('EVENT_DAEMON_AMQP_EXCHANGE')
    channel = os.environ.get('EVENT_HEARTBEAT_CHANNEL')
    appid = os.environ.get('EVENT_PUBLISHER_APPID')

    # sensible defaults
    channel = channel or 'judge.status.update'
    exchange = exchange or 'dmoj-events'
    appid = appid or 'judge'

    if not broker:
        raise RuntimeError('No AMQP broker configured. Set EVENT_DAEMON_AMQP or configure Django settings.')
    return broker, exchange, channel, appid


def publish_heartbeat():
    broker, exchange_name, channel, appid = get_config()
    exchange = Exchange(exchange_name, type='topic', durable=True)
    conn = Connection(broker)
    envelope_id = str(uuid.uuid4())
    ts = int(time.time())
    envelope = {
        'id': envelope_id,
        'channel': channel,
        'message': {
            'content': 'dummy',
            'ts': ts,
        }
    }

    logger.info('Connecting to broker %s, exchange=%s, routing_key=%s', broker, exchange_name, channel)
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
    logger.info('Published heartbeat id=%s channel=%s ts=%s', envelope_id, channel, ts)


if __name__ == '__main__':
    try:
        publish_heartbeat()
    except Exception as e:
        logger.exception('Failed to publish heartbeat: %s', e)
        raise
