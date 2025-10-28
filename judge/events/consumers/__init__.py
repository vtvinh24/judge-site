"""Consumers package for events (Kombu-based consumers).

This package provides small handler modules for each event schema. Each
consumer module exposes a `handle_event(envelope, message=None)` function
which can be wired into dispatch logic.
"""

__all__ = [
	"artifact_event",
	"build_result_event",
	"evaluation_progress",
	"evaluation_started_event",
	"hooks_result_event",
	"package_validated_event",
	"result_event",
	"status_event",
]
