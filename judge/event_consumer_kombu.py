"""Compatibility shim for the old top-level consumer.

The real consumer implementation lives under ``judge.events.consumers``. This
module re-exports the primary class so existing callers continue to work.
"""
import warnings
from judge.events.consumers.consumer import EventConsumer as _EventConsumer

warnings.warn('judge.event_consumer_kombu is deprecated; import judge.events.consumers.consumer.EventConsumer instead', DeprecationWarning)

EventConsumer = _EventConsumer

__all__ = ['EventConsumer']
