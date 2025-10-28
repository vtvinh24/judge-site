Event consumer prototype
=======================

This folder contains a tiny prototype consumer for DMOJ → JUDGE events
using the in-memory queue in `judge/event_queue.py`.

Files
- `consumer.py` — loads message schemas from `docs/schemas/messages`,
  performs lightweight validation and dispatches to handler functions.
- `handlers.py` — concrete handler implementations for a few channels
  used by the prototype (`package.submitted`, `submission.submitted`,
  `image.build.request`).

Quick start

Run the consumer in the background (it uses the prototype queue):

```bash
python -c "import events.consumer as c; c.start_consumer(); print('consumer started')"
```

You can publish test events using the prototype queue, for example:

```bash
python - <<'PY'
from judge import event_queue

event_queue.publish('dmoj.submission.submitted', { 'submission_id': 's1', 'problem_id': 'p1', 'package_url': 'http://example.com/pkg' })
PY
```

Notes
- The schema validator is minimal and intended only for top-level
  checks during early integration testing. Replace it with `jsonschema`
  or another full validator for production use.
