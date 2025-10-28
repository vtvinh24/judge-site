"""Compatibility shim for schema utilities.

New implementation lives in ``judge.events.schemas``. This module re-exports
that API for callers that still import ``judge.event_schemas``.
"""
import warnings
from judge.events import schemas as _schemas

warnings.warn('judge.event_schemas is deprecated; import judge.events.schemas instead', DeprecationWarning)

load_schemas = _schemas.load_schemas
get_schema_for_channel = _schemas.get_schema_for_channel
validate_payload = _schemas.validate_payload
example_channels = _schemas.example_channels

__all__ = ['load_schemas', 'get_schema_for_channel', 'validate_payload', 'example_channels']
