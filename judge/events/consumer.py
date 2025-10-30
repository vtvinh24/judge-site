"""AMQP message queue consumer for DMOJ events.

This consumer listens on the configured AMQP exchange and routes incoming messages
to the appropriate handler based on the routing key. It expects messages in the format
used by the judge system, where each message contains:
- fields.exchange: The exchange name, default to "domj-events"
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
            # Try to resolve routing/exchange information from multiple places.
            routing_key = None
            exchange = None

            # Case A: message.delivery_info available (kombu.Message)
            if message is not None and getattr(message, 'delivery_info', None):
                di = message.delivery_info
                routing_key = di.get('routing_key') or di.get('routingKey')
                exchange = di.get('exchange')

            # Case B: Some transports deliver the full fields/properties/content
            # as the body (e.g., an HTTP bridge or a JS-side JSON representation).
            # This format contains `fields` with routingKey and `content` which
            # may be a Node-style Buffer: { type: 'Buffer', data: [ ...bytes ] }
            envelope = None
            if isinstance(body, dict) and 'fields' in body and 'content' in body:
                fields = body.get('fields') or {}
                props = body.get('properties') or {}
                content = body.get('content')

                routing_key = routing_key or fields.get('routingKey') or fields.get('routing_key')
                exchange = exchange or fields.get('exchange')

                # Decode content if it's a Buffer-like dict with a data array
                decoded_payload = None
                if isinstance(content, dict) and 'data' in content and isinstance(content.get('data'), list):
                    try:
                        content_bytes = bytes(content.get('data') or [])
                        # Try JSON decode
                        decoded_payload = json.loads(content_bytes.decode('utf-8')) if content_bytes else None
                    except Exception:
                        # Fall back to raw string
                        try:
                            decoded_payload = content_bytes.decode('utf-8')
                        except Exception:
                            decoded_payload = None
                else:
                    # If content is a raw string or already-decoded object
                    try:
                        decoded_payload = json.loads(content) if isinstance(content, str) else content
                    except Exception:
                        decoded_payload = content

                # The bridge may have encoded the original envelope inside the content,
                # or the message body itself may contain a `message` field.
                if isinstance(decoded_payload, dict) and ('id' in decoded_payload and 'message' in decoded_payload):
                    envelope = decoded_payload
                else:
                    # If the body has a top-level `message` field, use that.
                    if 'message' in body and isinstance(body.get('message'), dict):
                        envelope = body.get('message')
                    else:
                        # Otherwise, use the decoded_payload directly (may already be the envelope)
                        envelope = decoded_payload or body.get('message') or body

            else:
                # Case C: Body may already be the envelope produced by poster.post()
                if isinstance(body, dict) and 'id' in body and 'channel' in body and 'message' in body:
                    envelope = body
                    routing_key = routing_key or body.get('channel')
                elif isinstance(body, bytes):
                    try:
                        envelope = json.loads(body.decode('utf-8'))
                        routing_key = routing_key or (envelope.get('channel') if isinstance(envelope, dict) else None)
                    except Exception:
                        logger.warning('Failed to JSON-decode byte message body')
                        envelope = None
                else:
                    envelope = body

            logger.debug(
                'Received message on exchange=%s routing_key=%s delivery_tag=%s',
                exchange, routing_key, getattr(message, 'delivery_tag', None)
            )
            logger.debug('Resolved envelope: %s', envelope)

            # Resolve a routing key string to find a handler. Prefer explicit routing_key
            # from fields/delivery_info, fall back to envelope.channel if present.
            resolved_routing_key = routing_key or (envelope.get('channel') if isinstance(envelope, dict) else None)

            # Look up handler for this routing key
            handler = get_handler(resolved_routing_key)

            if handler:
                logger.info('Dispatching to handler for routing_key=%s', resolved_routing_key)
                try:
                    # Pass the envelope in the same shape produced by poster.post() when possible.
                    # If envelope contains only the message payload, normalize to {id, channel, message}.
                    normalized = envelope
                    if isinstance(envelope, dict) and 'message' not in envelope and ('submission_id' in envelope or 'submissionId' in envelope):
                        # Create minimal envelope around the payload
                        normalized = {'id': None, 'channel': resolved_routing_key, 'message': envelope}

                    handler(normalized, message)
                    if message is not None:
                        message.ack()
                        logger.debug('Message acknowledged: delivery_tag=%s', getattr(message, 'delivery_tag', None))
                except Exception as e:
                    logger.exception('Handler failed for routing_key=%s: %s', resolved_routing_key, e)
                    if message is not None:
                        # Reject and don't requeue if handler fails
                        message.reject(requeue=False)
            else:
                logger.warning('No handler registered for routing_key=%s', resolved_routing_key)
                # Acknowledge messages with no handler to prevent queue buildup
                if message is not None:
                    message.ack()

        except Exception as e:
            logger.exception('Error processing message: %s', e)
            if message is not None:
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
        # Ensure handler is registered in this module's registry. Some import
        # ordering or module reloads can cause the consumer's _HANDLERS dict to
        # be empty even if the consumer module was referenced elsewhere; as a
        # defensive fallback, register the known result handler here if it's
        # available but not yet present in our registry.
        try:
            if 'judge.result.created' not in _HANDLERS and hasattr(result, 'handle_result_event'):
                register_handler('judge.result.created', result.handle_result_event)
                logger.info('Fallback-registered result handler for routing key: judge.result.created')
        except Exception:
            # Non-fatal: continue if fallback registration fails
            logger.exception('Fallback registration of result handler failed')
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
