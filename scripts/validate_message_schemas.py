#!/usr/bin/env python3
import json
import sys
from pathlib import Path
try:
    from jsonschema import Draft7Validator
except Exception:
    print('Missing dependency: jsonschema. Please install with `pip install jsonschema`', file=sys.stderr)
    sys.exit(3)

base = Path('docs/schemas/messages')
if not base.exists():
    print('Directory not found:', base)
    sys.exit(2)

ok = True
for p in sorted(base.glob('*.json')):
    print('\n==', p)
    try:
        s = json.loads(p.read_text())
    except Exception as e:
        print('JSON LOAD ERROR:', e)
        ok = False
        continue
    try:
        Draft7Validator.check_schema(s)
        print('SCHEMA OK')
    except Exception as e:
        print('SCHEMA ERROR:', e)
        ok = False

if not ok:
    print('\nOne or more schemas failed validation')
    sys.exit(1)
print('\nAll schemas validated successfully')
sys.exit(0)
