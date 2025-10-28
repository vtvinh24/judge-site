import json
import threading
from time import time

import pika
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
            # Note: routing_key is currently empty string; exchange bindings determine delivery.
            self._chan.basic_publish(self._exchange, '', payload)
            logger.debug('Published event id=%s channel=%s exchange=%s size=%d', id, channel, self._exchange, len(payload))
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
