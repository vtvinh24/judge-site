"""Event consumer package for prototyping DMOJ ↔ JUDGE message handlers.

This package contains a small consumer and a few handler functions that
demonstrate processing incoming events (from DMOJ) and emitting simple
response events (from JUDGE). It integrates with the in-memory
prototype queue in `judge/event_queue.py` so it can be used for local
integration testing.

This is intentionally lightweight and self-contained (no external
dependencies). The validator in `consumer.py` implements a small subset
of JSON Schema behaviour sufficient for top-level checks used in the
message schemas in `docs/schemas/messages`.
"""

from .consumer import start_consumer, stop_consumer, handle_event

__all__ = ["start_consumer", "stop_consumer", "handle_event"]
