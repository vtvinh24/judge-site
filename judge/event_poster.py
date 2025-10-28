from django.conf import settings
import os
import threading
import time
import json
from queue import Queue

__all__ = ['last', 'post']

# Simple in-process event queue used when external event daemons/transports
# are not enabled. This implementation just writes each event to a
# `log.txt` file under settings.BASE_DIR (or cwd) so events can be
# inspected during development/testing.
if not settings.EVENT_DAEMON_USE:
    real = False

    _queue = Queue()
    _last_event = None
    _counter = 0
    _lock = threading.Lock()
    _started = False

    # events directory under BASE_DIR (or cwd) is used to store event
    # definition files (one file per event). Logging should live under
    # a separate logs/events/ directory so the events/ directory remains
    # clean for definitions.
    _events_dir = os.path.join(getattr(settings, 'BASE_DIR', os.getcwd()), 'events')
    _logs_events_dir = os.path.join(getattr(settings, 'BASE_DIR', os.getcwd()), 'logs', 'events')
    _combined_log = os.path.join(_logs_events_dir, 'log.txt')

    def _ensure_events_dir():
        try:
            os.makedirs(_events_dir, exist_ok=True)
        except Exception:
            # best-effort: if creation fails, fallback to cwd
            pass

    def _ensure_logs_dir():
        try:
            os.makedirs(_logs_events_dir, exist_ok=True)
        except Exception:
            # best-effort: if creation fails, fallback to cwd
            pass

    def _safe_event_filename(ev_id, ts):
        # produce a short filename prefix safe for most filesystems
        t = int(ts)
        return os.path.join(_events_dir, f"event_{ev_id}_{t}.json")

    def _consumer():
        _ensure_events_dir()
        while True:
            channel, message, ev_id, ts = _queue.get()
            try:
                record = {
                    'ts': ts,
                    'event_id': ev_id,
                    'channel': channel,
                    'message': message,
                }
                # write individual event file
                try:
                    path = _safe_event_filename(ev_id, ts)
                    with open(path, 'w', encoding='utf-8') as f:
                        f.write(json.dumps(record, default=str))
                except Exception:
                    # ignore per-file write errors
                    pass

                # append to combined log under logs/events/
                try:
                    _ensure_logs_dir()
                    with open(_combined_log, 'a', encoding='utf-8') as f:
                        f.write(json.dumps(record, default=str) + "\n")
                except Exception:
                    # ignore append failures
                    pass
            finally:
                _queue.task_done()

    def _heartbeat_loop(interval=10.0):
        # Post a periodic heartbeat event. Uses post() which will enqueue the
        # heartbeat for the consumer to write.
        while True:
            time.sleep(interval)
            try:
                # small, serializable heartbeat payload
                post('judge.heartbeat', {'ts': time.time(), 'source': 'local-event-poster'})
            except Exception:
                # don't let heartbeat thread die on exceptions
                continue

    def _start_consumer_if_needed():
        global _started
        with _lock:
            if _started:
                return
            # mark started early to avoid races when threads call post()
            _started = True

        # create events dir before starting threads
        _ensure_events_dir()

        t = threading.Thread(target=_consumer, name='event_poster_local', daemon=True)
        t.start()
        hb = threading.Thread(target=_heartbeat_loop, name='event_poster_heartbeat', daemon=True)
        hb.start()

    def post(channel, message):
        """Enqueue an event. Returns a simple integer event id."""
        global _counter, _last_event
        _start_consumer_if_needed()
        with _lock:
            _counter += 1
            ev_id = _counter
            ts = time.time()
            _last_event = (ts, ev_id, channel, message)
            # Put a simple serializable payload (message may be dict/string)
            _queue.put((channel, message, ev_id, ts))
            return ev_id

    def last():
        """Return the last posted event as a tuple (timestamp, event_id, channel, message)
        or None if no events have been posted."""
        return _last_event
elif hasattr(settings, 'EVENT_DAEMON_AMQP'):
    from .event_poster_amqp import last, post
    real = True
else:
    from .event_poster_ws import last, post
    real = True
