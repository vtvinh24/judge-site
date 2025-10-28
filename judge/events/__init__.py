"""Centralized event handlers package.

Structure:
- judge/events/publishers    # publisher scripts (heartbeat, etc.)
- judge/events/consumers     # consumer daemons
- judge/events/schemas       # schema loader/validator helpers

Future handlers should be added under the appropriate subpackage.
"""

__all__ = ["publishers", "consumers", "schemas"]
