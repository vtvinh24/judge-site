"""Simple in-process event queue for prototyping.

This module provides a tiny publish/consume API and writes POSTED/CAUGHT
entries to a local `log.txt` file in the project root to make it easy to
observe when events are fired and when they're processed.

Usage:
    from judge import event_queue

    event_queue.publish("dmoj.submission.submitted", {"submission_id": 1})

    def handler(channel, message):
        print("handled", channel, message)

    event_queue.consume(handler)  # starts a background consumer thread

This is a minimal prototype and is not durable across process restarts.
"""
from __future__ import annotations

import json
import os
import threading
import queue
import datetime
from typing import Callable, Any

_EVENT_QUEUE: queue.Queue = queue.Queue()
_LOG_PATH = os.path.join(os.getcwd(), "log.txt")
_LOG_LOCK = threading.Lock()
_consumer_thread = None


def _write_log(line: str) -> None:
    with _LOG_LOCK:
        with open(_LOG_PATH, "a", encoding="utf-8") as f:
            f.write(line + "\n")


def _now_iso() -> str:
    return datetime.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"


def publish(channel: str, message: Any) -> int:
    """Publish an event to the in-memory queue and append a POSTED line to log.txt.

    Returns 1 on success (mimics the post() API used elsewhere).
    """
    event = {
        "channel": channel,
        "message": message,
        "timestamp": _now_iso(),
    }
    # enqueue
    _EVENT_QUEUE.put(event)

    # log POSTED
    try:
        _write_log(json.dumps({"marker": "POSTED", "ts": event["timestamp"], "channel": channel, "message": message}, default=str))
    except Exception:
        # best-effort logging; swallow errors so callers don't crash
        pass
    return 1


def _consumer_loop(handler: Callable[[str, Any], None], stop_event: threading.Event) -> None:
    while not stop_event.is_set():
        try:
            event = _EVENT_QUEUE.get(timeout=0.5)
        except queue.Empty:
            continue

        ts = _now_iso()
        try:
            handler(event["channel"], event["message"])
            _write_log(json.dumps({"marker": "CAUGHT", "ts": ts, "channel": event["channel"], "message": event["message"]}, default=str))
        except Exception as exc:  # capture handler exceptions and log them
            _write_log(json.dumps({"marker": "HANDLER_ERROR", "ts": ts, "channel": event["channel"], "error": str(exc)}, default=str))


def consume(handler: Callable[[str, Any], None]) -> threading.Event:
    """Start a background daemon thread that calls handler(channel, message) for each published event.

    Returns a threading.Event that can be set() to stop the consumer.
    """
    global _consumer_thread
    stop_event = threading.Event()

    if _consumer_thread and _consumer_thread.is_alive():
        # already running — don't start another
        return stop_event

    _consumer_thread = threading.Thread(target=_consumer_loop, args=(handler, stop_event), daemon=True)
    _consumer_thread.start()
    return stop_event


def consume_once(handler: Callable[[str, Any], None], timeout: float = None) -> bool:
    """Process a single queued event (blocking). Returns True if an event was processed."""
    try:
        event = _EVENT_QUEUE.get(timeout=timeout)
    except queue.Empty:
        return False

    ts = _now_iso()
    try:
        handler(event["channel"], event["message"])
        _write_log(json.dumps({"marker": "CAUGHT", "ts": ts, "channel": event["channel"], "message": event["message"]}, default=str))
    except Exception as exc:
        _write_log(json.dumps({"marker": "HANDLER_ERROR", "ts": ts, "channel": event["channel"], "error": str(exc)}, default=str))
    return True


__all__ = ["publish", "consume", "consume_once"]
