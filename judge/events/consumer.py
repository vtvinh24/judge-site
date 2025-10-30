"""AMQP message queue consumer for DMOJ events.

This consumer listens on the configured AMQP exchange and routes incoming messages
to the appropriate handler based on the routing key. It expects messages in the format
used by the judge system, where each message contains:
- fields.exchange: The exchange name
- fields.routingKey: The routing key (used to route to handlers)
- content: The actual payload (Buffer that needs to be decoded)

Example message structure:
```
fields: {
    "consumerTag": "amq.ctag-44zWxXxfgQW3ThrqkjLT3w",
    "deliveryTag": 4,
    "redelivered": false,
    "exchange": "dmoj-events",
    "routingKey": "judge.result.created"
}
properties: {
    "headers": {}
}
content: {
    "type": "Buffer",
    "data": [...]
}
```
"""
import json
import logging
import os
import signal
import sys

from kombu import Connection, Exchange, Queue
from kombu.mixins import ConsumerMixin
from django.conf import settings

logger = logging.getLogger('judge.events.consumer')


def _get_broker_url():
    """Get the AMQP broker URL from settings or environment."""
    return (
        getattr(settings, 'EVENT_DAEMON_AMQP', None) 
        or getattr(settings, 'CELERY_BROKER_URL', None) 
        or os.environ.get('EVENT_DAEMON_AMQP')
    )


def _get_exchange_name():
    """Get the exchange name from settings or environment."""
    return getattr(settings, 'EVENT_DAEMON_AMQP_EXCHANGE', 'dmoj-events')


# Registry of routing key patterns to handler functions
# Handler signature: handler(envelope: dict, message: kombu.Message) -> None
_HANDLERS = {}


def register_handler(routing_key: str, handler):
    """Register a handler function for a specific routing key pattern.
    
    Args:
        routing_key: The routing key pattern (e.g., 'judge.result.created')
        handler: A callable that accepts (envelope: dict, message: kombu.Message)
    """
    _HANDLERS[routing_key] = handler
    logger.info('Registered handler for routing key: %s', routing_key)


def get_handler(routing_key: str):
    """Get the handler for a specific routing key.
    
    Args:
        routing_key: The routing key to look up
        
    Returns:
        The handler function or None if not found
    """
    return _HANDLERS.get(routing_key)


class DMOJEventConsumer(ConsumerMixin):
    """Kombu consumer that listens for DMOJ events and dispatches to handlers."""
    
    def __init__(self, connection, exchange_name):
        self.connection = connection
        self.exchange_name = exchange_name
        self.exchange = Exchange(exchange_name, type='topic', durable=True)
        logger.info('Initialized DMOJ event consumer for exchange: %s', exchange_name)
        
    def get_consumers(self, Consumer, channel):
        """Set up consumers for the exchange.
        
        We bind to all routing keys (#) to capture all messages on the exchange.
        """
        queue = Queue(
            name='',  # Empty name creates an exclusive auto-delete queue
            exchange=self.exchange,
            routing_key='#',  # Bind to all routing keys
            exclusive=True,
            auto_delete=True,
        )
        
        return [
            Consumer(
                queues=[queue],
                callbacks=[self.on_message],
                accept=['json'],
            )
        ]
    
    def on_message(self, body, message):
        """Handle incoming messages.
        
        Args:
            body: The decoded message body (envelope containing id, channel, message)
            message: The Kombu Message object with delivery info
        """
        try:
            # Extract routing key from message delivery info
            routing_key = message.delivery_info.get('routing_key', '')
            exchange = message.delivery_info.get('exchange', '')
            
            logger.debug(
                'Received message on exchange=%s routing_key=%s delivery_tag=%s',
                exchange, routing_key, message.delivery_tag
            )
            
            # The body should be the envelope with {id, channel, message}
            # If it's a raw buffer, we need to handle it differently
            if isinstance(body, dict):
                envelope = body
            elif isinstance(body, bytes):
                envelope = json.loads(body.decode('utf-8'))
            else:
                logger.warning('Unexpected message body type: %s', type(body))
                message.ack()
                return
            
            logger.debug('Decoded envelope: %s', envelope)
            
            # Look up handler for this routing key
            handler = get_handler(routing_key)
            
            if handler:
                logger.info('Dispatching to handler for routing_key=%s', routing_key)
                try:
                    handler(envelope, message)
                    message.ack()
                    logger.debug('Message acknowledged: delivery_tag=%s', message.delivery_tag)
                except Exception as e:
                    logger.exception('Handler failed for routing_key=%s: %s', routing_key, e)
                    # Reject and don't requeue if handler fails
                    message.reject(requeue=False)
            else:
                logger.warning('No handler registered for routing_key=%s', routing_key)
                # Acknowledge messages with no handler to prevent queue buildup
                message.ack()
                
        except Exception as e:
            logger.exception('Error processing message: %s', e)
            message.reject(requeue=False)


def run_consumer():
    """Run the consumer in a blocking loop.
    
    This function will block indefinitely, consuming messages from the queue.
    It should typically be run in a dedicated process or thread.
    """
    broker = _get_broker_url()
    if not broker:
        logger.error('No AMQP broker configured. Set EVENT_DAEMON_AMQP or CELERY_BROKER_URL.')
        sys.exit(1)
    
    exchange_name = _get_exchange_name()
    
    # Import and register handlers
    # We do this here to avoid circular imports and to ensure Django is set up
    try:
        from judge.events.consumers import result
        logger.info('Loaded result event handlers')
    except ImportError as e:
        logger.warning('Could not load result handlers: %s', e)
    
    logger.info('Starting DMOJ event consumer')
    logger.info('Broker: %s', broker)
    logger.info('Exchange: %s', exchange_name)
    logger.info('Registered handlers: %s', list(_HANDLERS.keys()))
    
    # Set up graceful shutdown
    shutdown_flag = {'stop': False}
    
    def signal_handler(signum, frame):
        logger.info('Received signal %s, shutting down...', signum)
        shutdown_flag['stop'] = True
    
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    conn = Connection(broker)
    consumer = DMOJEventConsumer(conn, exchange_name)
    
    try:
        consumer.run()
    except KeyboardInterrupt:
        logger.info('Keyboard interrupt received, shutting down')
    except Exception as e:
        logger.exception('Consumer error: %s', e)
        sys.exit(1)
    finally:
        logger.info('Consumer stopped')


if __name__ == '__main__':
    # Set up Django if running standalone
    import django
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dmoj.settings')
    django.setup()
    
    run_consumer()
