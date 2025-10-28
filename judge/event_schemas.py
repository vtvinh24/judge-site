import json
import os
from functools import lru_cache
from typing import Optional

from django.conf import settings
from jsonschema import validate, Draft7Validator, ValidationError


SCHEMA_DIR = os.path.join(settings.BASE_DIR, 'docs', 'schemas', 'messages')


@lru_cache(maxsize=1)
def load_schemas():
    """Load all JSON Schema files under docs/schemas/messages and return mapping:
    channel -> schema dict

    Schemas that contain a top-level `x-channel` property will be registered
    under that channel. If a schema lacks `x-channel` it will be ignored.
    """
    mapping = {}
    if not os.path.isdir(SCHEMA_DIR):
        return mapping
    for fname in os.listdir(SCHEMA_DIR):
        if not fname.endswith('.json') and not fname.endswith('.schema.json'):
            continue
        path = os.path.join(SCHEMA_DIR, fname)
        try:
            with open(path, 'r') as f:
                doc = json.load(f)
        except Exception:
            continue
        channel = doc.get('x-channel')
        if channel:
            mapping[channel] = doc
    return mapping


def get_schema_for_channel(channel: str) -> Optional[dict]:
    return load_schemas().get(channel)


def validate_payload(channel: str, payload: dict) -> None:
    """Validate payload dict against the schema registered for channel.

    Raises jsonschema.ValidationError if invalid, KeyError if schema not found.
    """
    schema = get_schema_for_channel(channel)
    if schema is None:
        raise KeyError(f'No schema registered for channel {channel}')
    # Many of our schemas expect the event payload as `payload` or full envelope.
    # Here we assume `payload` is the inner message portion; callers should pass the
    # correct object depending on schema shape.
    validator = Draft7Validator(schema)
    errors = sorted(validator.iter_errors(payload), key=lambda e: e.path)
    if errors:
        # Raise the first error for simplicity
        raise ValidationError(errors[0].message)


def example_channels():
    return list(load_schemas().keys())
