import json
import os
from functools import lru_cache
from typing import Optional

from jsonschema import Draft7Validator, ValidationError
from django.conf import settings


SCHEMA_DIR = os.path.join(getattr(settings, 'BASE_DIR', os.getcwd()), 'docs', 'schemas', 'messages')


@lru_cache(maxsize=1)
def load_schemas():
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
    schema = get_schema_for_channel(channel)
    if schema is None:
        raise KeyError(f'No schema registered for channel {channel}')
    validator = Draft7Validator(schema)
    errors = sorted(validator.iter_errors(payload), key=lambda e: e.path)
    if errors:
        raise ValidationError(errors[0].message)


def example_channels():
    return list(load_schemas().keys())
