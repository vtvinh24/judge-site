import logging
import time

from kombu import Connection, Exchange, Queue, Consumer
from kombu.exceptions import KombuError
from django.conf import settings
from jsonschema import ValidationError

from . import event_schemas

logger = logging.getLogger('judge.event_consumer')


class EventConsumer:
    def __init__(self, broker_url=None, exchange_name=None, queue_name=None, routing_keys=None):
        self.broker_url = broker_url or getattr(settings, 'EVENT_DAEMON_AMQP', None) or getattr(settings, 'CELERY_BROKER_URL', None)
        if not self.broker_url:
            raise RuntimeError('No AMQP broker URL configured (set EVENT_DAEMON_AMQP or CELERY_BROKER_URL)')
        self.exchange_name = exchange_name or getattr(settings, 'EVENT_DAEMON_AMQP_EXCHANGE', 'dmoj-events')
        self.queue_name = queue_name or getattr(settings, 'EVENT_CONSUMER_QUEUE', 'dmoj-events-consumer')
        self.routing_keys = routing_keys or getattr(settings, 'EVENT_DAEMON_BIND_KEYS', ['#'])
        self.exchange = Exchange(self.exchange_name, type='topic', durable=True)
        self.conn = Connection(self.broker_url, heartbeat=30)

    def _handle(self, body, message):
        try:
            # Expect envelope of shape {id, channel, message}
            channel = body.get('channel')
            inner = body.get('message')
            if not channel:
                logger.warning('Received event without channel; rejecting')
                message.reject()
                return
            schema = event_schemas.get_schema_for_channel(channel)
            if schema is None:
                # Unknown channel: log and ack to avoid redelivery loops (policy choice)
                logger.warning('No schema for channel %s; acking and skipping', channel)
                message.ack()
                return
            try:
                event_schemas.validate_payload(channel, inner)
            except ValidationError as e:
                logger.error('Validation failed for channel %s: %s', channel, e)
                # Reject and do not requeue (send to DLX if configured)
                message.reject()
                return
            # Dispatch placeholder: implement your own handlers or call into Django
            logger.info('Dispatching event channel=%s id=%s', channel, body.get('id'))
            # TODO: call actual handler, e.g., module-based dispatch
            message.ack()
        except Exception as e:
            logger.exception('Unexpected error handling message: %s', e)
            try:
                message.reject()
            except Exception:
                pass

    def start(self):
        # Declare a durable queue bound to requested routing keys
        queues = [Queue(self.queue_name, exchange=self.exchange, routing_key=key, durable=True) for key in self.routing_keys]
        try:
            with self.conn:
                with Consumer(self.conn, queues=queues, callbacks=[self._handle], accept=['json']):
                    logger.info('EventConsumer started, listening on %s (keys=%s)', self.queue_name, self.routing_keys)
                    while True:
                        try:
                            self.conn.drain_events(timeout=2)
                        except Exception:
                            # loop and continue; handle heartbeat etc.
                            time.sleep(0.1)
        except KombuError:
            logger.exception('Kombu connection error')


if __name__ == '__main__':
    c = EventConsumer()
    c.start()
