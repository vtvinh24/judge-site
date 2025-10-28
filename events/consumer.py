"""Small event consumer with lightweight JSON Schema-like validation.

This module loads JSON schemas from `docs/schemas/messages` and uses a
minimal validator (only a subset of draft-07 behaviour) to check
required properties, top-level property types and `additionalProperties`.

It dispatches to handler functions in `events.handlers` and publishes
simple response events using `judge.event_queue.publish`.
"""
from __future__ import annotations

import json
import os
import glob
from typing import Any, Dict, Tuple, List
import threading
import traceback

from judge import event_queue
from . import handlers

SCHEMAS_DIR = os.path.join(os.getcwd(), "docs", "schemas", "messages")


def _load_schemas() -> Dict[str, Dict[str, Any]]:
    schemas = {}
    pattern = os.path.join(SCHEMAS_DIR, "*.json")
    for path in glob.glob(pattern):
        try:
            with open(path, "r", encoding="utf-8") as f:
                data = json.load(f)
                name = os.path.basename(path)
                schemas[name] = data
        except Exception:
            # best-effort: continue loading other schemas
            print("warn: failed to load schema", path)
    return schemas


_SCHEMAS = _load_schemas()

# map channel -> schema filename (only top-level messages used by prototype)
CHANNEL_SCHEMA_MAP = {
    "dmoj.problem.package.submitted": "package_event.schema.json",
    "dmoj.submission.submitted": "submission_event.schema.json",
    "dmoj.problem.image.build.request": "build_request_event.schema.json",
}


def _type_matches(value: Any, schema_type: Any) -> bool:
    """Minimal mapping of JSON Schema 'type' to Python types.

    Accepts null or list-of-types in the schema.
    """
    if isinstance(schema_type, list):
        return any(_type_matches(value, t) for t in schema_type)
    if schema_type == "string":
        return value is None or isinstance(value, str) if schema_type == "string" else isinstance(value, str)
    if schema_type == "object":
        return isinstance(value, dict)
    if schema_type == "boolean":
        return isinstance(value, bool)
    if schema_type == "array":
        return isinstance(value, list)
    if schema_type == "number":
        return isinstance(value, (int, float)) and not isinstance(value, bool)
    if schema_type == "integer":
        return isinstance(value, int) and not isinstance(value, bool)
    if schema_type == "null":
        return value is None
    # unknown — be permissive
    return True


def validate(schema: Dict[str, Any], data: Dict[str, Any]) -> Tuple[bool, List[str]]:
    """Validate top-level behaviour:

    - required properties
    - oneOf (basic handling of required sets)
    - additionalProperties: false
    - simple type checks for declared top-level properties

    Returns (is_valid, errors)
    """
    errors: List[str] = []

    # handle oneOf at root (some schemas use oneOf for alternative required sets)
    if "oneOf" in schema:
        for subschema in schema["oneOf"]:
            req = subschema.get("required", [])
            if all(k in data for k in req):
                # consider this variant satisfied; still check types below
                break
        else:
            errors.append("none of the oneOf subschemas satisfied required fields")

    # required
    for req in schema.get("required", []):
        if req not in data:
            errors.append(f"missing required property: {req}")

    props = schema.get("properties", {})
    # additionalProperties
    if schema.get("additionalProperties", True) is False:
        for k in data.keys():
            if k not in props:
                errors.append(f"additional property not allowed: {k}")

    # top-level type checks
    for k, v in data.items():
        if k in props:
            p = props[k]
            expected = p.get("type")
            if expected is not None:
                if not _type_matches(v, expected):
                    errors.append(f"property {k} expected type {expected}, got {type(v).__name__}")

    return (len(errors) == 0, errors)


def handle_event(channel: str, message: Any) -> None:
    """Main dispatch for incoming events.

    This function validates the message where a schema is known and then
    forwards to the concrete handlers in `events.handlers`.
    """
    try:
        # expect an object payload
        if not isinstance(message, dict):
            print(f"invalid message type for channel {channel}: expected object")
            return

        schema_file = CHANNEL_SCHEMA_MAP.get(channel)
        if schema_file:
            schema = _SCHEMAS.get(schema_file)
            if schema:
                ok, errors = validate(schema, message)
                if not ok:
                    print(f"schema validation failed for {channel}:", errors)
                    return
            else:
                print(f"warning: schema file {schema_file} not loaded; skipping validation")

        # dispatch
        if channel == "dmoj.problem.package.submitted":
            handlers.handle_package_submitted(message)
        elif channel == "dmoj.submission.submitted":
            handlers.handle_submission_submitted(message)
        elif channel == "dmoj.problem.image.build.request":
            handlers.handle_build_request(message)
        else:
            # unknown channel — call generic handler
            handlers.handle_unknown(channel, message)

    except Exception:
        print("exception while handling event", channel)
        traceback.print_exc()


_consumer_stop_event = None


def start_consumer() -> None:
    """Start the background consumer using `judge.event_queue.consume`.

    This function is idempotent.
    """
    global _consumer_stop_event
    if _consumer_stop_event is not None:
        return
    _consumer_stop_event = event_queue.consume(handle_event)
    print("events.consumer: started consumer")


def stop_consumer() -> None:
    """Stop the background consumer if running."""
    global _consumer_stop_event
    if _consumer_stop_event is None:
        return
    _consumer_stop_event.set()
    _consumer_stop_event = None
    print("events.consumer: stopped consumer")


if __name__ == "__main__":
    # when run directly, start the consumer and print available schemas
    print("Loaded schemas:", list(_SCHEMAS.keys()))
    start_consumer()
    print("Consumer running (press Ctrl-C to stop).")
    try:
        # keep main thread alive
        threading.Event().wait()
    except KeyboardInterrupt:
        stop_consumer()
