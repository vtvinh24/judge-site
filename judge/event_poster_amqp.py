import json
import threading
from time import time

import pika
from pika import BasicProperties
import logging
from django.conf import settings
from pika.exceptions import AMQPError

__all__ = ['EventPoster', 'post', 'last']

# Module logger for AMQP event poster
logger = logging.getLogger('judge.event_poster_amqp')


class EventPoster(object):
    def __init__(self):
        self._connect()
        self._exchange = settings.EVENT_DAEMON_AMQP_EXCHANGE

    def _connect(self):
        try:
            self._conn = pika.BlockingConnection(pika.URLParameters(settings.EVENT_DAEMON_AMQP))
            self._chan = self._conn.channel()
            logger.info('Connected to AMQP broker %s (exchange=%s)', settings.EVENT_DAEMON_AMQP, self._exchange)
        except AMQPError:
            logger.exception('Failed to connect to AMQP broker %s', settings.EVENT_DAEMON_AMQP)
            raise

    def post(self, channel, message, tries=0):
        try:
            id = int(time() * 1000000)
            payload = json.dumps({'id': id, 'channel': channel, 'message': message})
            # Prepare AMQP properties: keep messages persistent and typed
            try:
                ts = int(time())
            except Exception:
                ts = None
            props = BasicProperties(
                content_type='application/json',
                delivery_mode=2,
                message_id=str(id),
                timestamp=ts,
                type=channel,
                app_id=getattr(settings, 'EVENT_PUBLISHER_APPID', 'judge')
            )
            # Summarize message for logging (avoid huge dumps)
            try:
                if isinstance(message, dict):
                    # show keys and up to 3 items for quick context
                    keys = list(message.keys())[:3]
                    summary = {k: message.get(k) for k in keys}
                else:
                    summary = str(message)[:200]
            except Exception:
                summary = '<unserializable>'

            # Publish using channel as routing key so consumers can bind selectively.
            # Exchange type should be 'topic' for wildcard subscriptions.
            self._chan.basic_publish(self._exchange, channel, payload, properties=props)
            # Log a concise human-readable line plus a debug payload for deeper inspection
            logger.info('Published event id=%s channel=%s exchange=%s size=%d summary=%s',
                        id, channel, self._exchange, len(payload), summary)
            logger.debug('Published event payload=%s', payload)
            return id
        except AMQPError:
            logger.warning('AMQP publish error on try %d for channel %s; attempting reconnect', tries, channel)
            if tries > 10:
                logger.error('AMQP publish failed after %d retries for channel %s', tries, channel)
                raise
            # attempt reconnect and retry
            try:
                self._connect()
            except AMQPError:
                # connection attempt failed; bubble up to caller after logging
                logger.exception('Reconnect attempt failed during publish retry')
                raise
            return self.post(channel, message, tries + 1)


_local = threading.local()


def _get_poster():
    if 'poster' not in _local.__dict__:
        logger.debug('Creating thread-local EventPoster')
        _local.poster = EventPoster()
    return _local.poster


def post(channel, message):
    try:
        return _get_poster().post(channel, message)
    except AMQPError:
        logger.exception('AMQPError in post(); discarding poster and returning 0')
        try:
            del _local.poster
        except AttributeError:
            pass
    return 0


def last():
    return int(time() * 1000000)
