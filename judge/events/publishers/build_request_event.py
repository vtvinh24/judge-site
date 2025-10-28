"""Publisher for build request events."""
import logging
import uuid
import os

from kombu import Connection, Exchange, Producer

from judge.events import schemas as event_schemas

logger = logging.getLogger('judge.events.publishers.build_request_event')


def publish(payload: dict, broker_url: str = None, exchange_name: str = None, channel: str = None, appid: str = None):
    broker = broker_url or os.environ.get('EVENT_DAEMON_AMQP')
    exchange_name = exchange_name or os.environ.get('EVENT_DAEMON_AMQP_EXCHANGE', 'dmoj-events')
    channel = channel or os.environ.get('EVENT_BUILD_REQUEST_CHANNEL', 'judge.build.request')
    appid = appid or os.environ.get('EVENT_PUBLISHER_APPID', 'judge')

    if broker is None:
        raise RuntimeError('No AMQP broker configured')

    if event_schemas.get_schema_for_channel(channel) is not None:
        event_schemas.validate_payload(channel, payload)

    envelope = {'id': str(uuid.uuid4()), 'channel': channel, 'message': payload}

    exchange = Exchange(exchange_name, type='topic', durable=True)
    conn = Connection(broker)
    with conn:
        producer = Producer(conn)
        producer.publish(envelope, exchange=exchange, routing_key=channel, serializer='json', declare=[exchange],
                         retry=True, retry_policy={'max_retries': 3}, headers={'app_id': appid}, delivery_mode=2)
    logger.info('Published build request event %s', envelope['id'])
