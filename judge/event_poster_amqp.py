"""Deprecated module kept for compatibility.

Use :mod:`judge.events.poster` instead. This module re-exports the newer
poster API and emits a deprecation warning.
"""
import warnings
from judge.events import poster as _poster

warnings.warn('judge.event_poster_amqp is deprecated; import judge.events.poster instead', DeprecationWarning)

post = _poster.post
last = _poster.last
real = _poster.real

__all__ = ['post', 'last', 'real']
