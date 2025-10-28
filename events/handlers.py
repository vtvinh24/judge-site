"""Concrete handlers for incoming events.

Handlers are intentionally small and focus on demonstrating the
interaction between DMOJ→JUDGE messages and simple JUDGE→DMOJ replies
for the prototype queue.
"""
from __future__ import annotations

import datetime
from typing import Any, Dict

from judge import event_queue


def _now_iso() -> str:
    return datetime.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"


def handle_package_submitted(message: Dict[str, Any]) -> None:
    """Handle `dmoj.problem.package.submitted`.

    Emits a simulated `dmoj.problem.package.validated` event to indicate
    the package was accepted. This is a prototype: in a real system this
    would run full validation and potentially enqueue builds.
    """
    package_id = message.get("package_id")
    payload = {
        "package_id": package_id,
        "validated": True,
        "validated_at": _now_iso(),
        "notes": "Prototype: package accepted by local consumer",
    }
    # publish back to the queue (JUDGE → DMOJ)
    event_queue.publish("dmoj.problem.package.validated", payload)


def handle_submission_submitted(message: Dict[str, Any]) -> None:
    """Handle `dmoj.submission.submitted`.

    Emits a `judge.evaluation.started` event and records a minimal
    evaluator id. For the prototype, no actual evaluation is performed.
    """
    submission_id = message.get("submission_id")
    problem_id = message.get("problem_id")
    payload = {
        "submission_id": submission_id,
        "problem_id": problem_id,
        "started_at": _now_iso(),
        "evaluator_id": "proto-evaluator-1",
        "worker_info": {"host": "local-proto", "note": "in-memory prototype"},
    }
    event_queue.publish("judge.evaluation.started", payload)


def handle_build_request(message: Dict[str, Any]) -> None:
    """Handle `dmoj.problem.image.build.request`.

    This function simulates a fast build and emits a success
    `dmoj.problem.image.build.completed` event.
    """
    problem_id = message.get("problem_id")
    build_job_id = f"build-{int(datetime.datetime.utcnow().timestamp())}"
    payload = {
        "problem_id": problem_id,
        "build_job_id": build_job_id,
        "status": "completed",
        "image_refs": {"eval": f"local/{problem_id}:latest"},
        "logs_url": None,
    }
    event_queue.publish("dmoj.problem.image.build.completed", payload)


def handle_unknown(channel: str, message: Dict[str, Any]) -> None:
    """Fallback handler that logs unknown channels by publishing a status event."""
    payload = {"channel": channel, "received_at": _now_iso(), "note": "unhandled in prototype"}
    event_queue.publish("judge.status", payload)
