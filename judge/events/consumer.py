import logging
import time

from kombu import Connection, Exchange, Queue, Consumer
from kombu.exceptions import KombuError
from jsonschema import ValidationError

from judge.events import schemas as event_schemas
from judge.events.consumers import result_event as result_consumer

logger = logging.getLogger('judge.events.consumers.consumer')


class EventConsumer:
    def __init__(self, broker_url, exchange_name='dmoj-events', queue_name='dmoj-events-consumer', routing_keys=None):
        self.broker_url = broker_url
        self.exchange_name = exchange_name
        self.queue_name = queue_name
        self.routing_keys = routing_keys or ['#']
        self.exchange = Exchange(self.exchange_name, type='topic', durable=True)
        self.conn = Connection(self.broker_url, heartbeat=30)

    def _handle(self, body, message):
        try:
            channel = body.get('channel')
            inner = body.get('message')
            if not channel:
                logger.warning('Received event without channel; rejecting')
                message.reject()
                return
            # Short-circuit result events: skip schema validation and dispatch
            # directly to the result_event handler so judge backends can react
            # to results in near-real-time.
            try:
                if channel and channel.startswith('judge.result'):
                    handled = result_consumer.handle_event(body, message)
                    if handled:
                        # Handler is responsible for ack/reject where needed.
                        return
            except Exception:
                logger.exception('Error dispatching to result_event handler')
            schema = event_schemas.get_schema_for_channel(channel)
            if schema is None:
                logger.warning('No schema for channel %s; acking and skipping', channel)
                message.ack()
                return
            try:
                event_schemas.validate_payload(channel, inner)
            except ValidationError as e:
                logger.error('Validation failed for channel %s: %s', channel, e)
                message.reject()
                return
            logger.info('Dispatching event channel=%s id=%s', channel, body.get('id'))
            message.ack()
        except Exception as e:
            logger.exception('Unexpected error handling message: %s', e)
            try:
                message.reject()
            except Exception:
                pass

    def start(self):
        queues = [Queue(self.queue_name, exchange=self.exchange, routing_key=key, durable=True) for key in self.routing_keys]
        try:
            with self.conn:
                with Consumer(self.conn, queues=queues, callbacks=[self._handle], accept=['json']):
                    logger.info('EventConsumer started, listening on %s (keys=%s)', self.queue_name, self.routing_keys)
                    while True:
                        try:
                            self.conn.drain_events(timeout=2)
                        except Exception:
                            time.sleep(0.1)
        except KombuError:
            logger.exception('Kombu connection error')


if __name__ == '__main__':
    import os
    broker = os.environ.get('EVENT_DAEMON_AMQP', 'amqp://guest:guest@rabbitmq:5672/')
    keys = os.environ.get('EVENT_DAEMON_BIND_KEYS', '#').split(',')
    c = EventConsumer(broker_url=broker, routing_keys=keys)
    c.start()
