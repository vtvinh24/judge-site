"""Backward-compatibility shim.

This module used to select the event poster backend. Event functionality has
been centralized under ``judge.events.poster``. Importing this module will
re-export that API but emit a deprecation notice.
"""
import warnings
from judge.events import poster as _poster

warnings.warn('judge.event_poster is deprecated; import judge.events.poster instead', DeprecationWarning)

post = _poster.post
last = _poster.last
real = _poster.real

__all__ = ['post', 'last', 'real']
