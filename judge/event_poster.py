from django.conf import settings
import logging

__all__ = ['last', 'post']

# Logger for event poster selection and lifecycle
logger = logging.getLogger('judge.event_poster')

if not settings.EVENT_DAEMON_USE:
    real = False
    logger.info('Event daemon disabled via settings.EVENT_DAEMON_USE')

    def post(channel, message):
        logger.debug('post() called while event daemon disabled; dropping event channel=%s', channel)
        return 0

    def last():
        return 0

elif hasattr(settings, 'EVENT_DAEMON_AMQP'):
    from .event_poster_amqp import last, post
    real = True
    logger.info('Event poster: using AMQP backend (exchange=%s)', getattr(settings, 'EVENT_DAEMON_AMQP_EXCHANGE', None))
else:
    from .event_poster_ws import last, post
    real = True
    logger.info('Event poster: using WebSocket backend')
