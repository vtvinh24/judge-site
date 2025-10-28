"""Publishers package for events.

This package contains small helper modules for publishing each supported
event schema. Each module exposes a `publish(payload, ...)` function.

To make imports more convenient we import the module-level ``publish``
functions into the package namespace with descriptive names. Callers can
either import the module (``from judge.events import publishers``) and
use ``publishers.publish_submission(...)`` or import the specific
function directly:

	from judge.events.publishers import publish_submission

This file intentionally keeps exports small and explicit.
"""

from .build_request_event import publish as publish_build_request
from .hooks_execute_request import publish as publish_hooks_execute_request
from .package_event import publish as publish_package
from .submission_event import publish as publish_submission

__all__ = [
	"publish_build_request",
	"publish_hooks_execute_request",
	"publish_package",
	"publish_submission",
]
