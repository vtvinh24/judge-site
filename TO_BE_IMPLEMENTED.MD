# To be implemented: DMOJ ↔ JUDGE message events

This document records the initial proposed message events and will be updated with analysis of existing code that already implements or partially implements each event.

Date: 2025-10-27

## Proposed events

1. dmoj.problem.package.submitted — DMOJ → JUDGE
2. dmoj.problem.package.validated — JUDGE → DMOJ
3. dmoj.problem.image.build.request — DMOJ → JUDGE
4. dmoj.problem.image.build.completed / dmoj.problem.image.build.failed — JUDGE → DMOJ
5. dmoj.submission.submitted — DMOJ → JUDGE
6. judge.evaluation.started — JUDGE → DMOJ
7. judge.evaluation.progress — JUDGE → DMOJ (optional)
8. result.evaluation.completed — JUDGE → DMOJ (existing schema: `judge-docs/schemas/result_event.schema.json`)
9. result.evaluation.failed — JUDGE → DMOJ
10. dmoj.artifact.uploaded — JUDGE → DMOJ
11. dmoj.hooks.execute.request — JUDGE → Hook executor / DMOJ (optional)
12. judge.status / dmoj.heartbeat — JUDGE → orchestrator (health/status)

---

## Implementation analysis (DMOJ ↔ JUDGE only)

Each entry below focuses only on DMOJ ↔ JUDGE communications. For each event I list whether implementation exists, relevant files, and short notes with suggested next actions.

1. dmoj.problem.package.submitted — DMOJ → JUDGE

   - implementation_exists: Partial
   - files:
     - `judge/handlers/problem_package.py` (create_problem_package)
     - `judge/admin/problem.py` (admin upload handling)
     - `judge/management/commands/import_problem_package.py`
     - `judge-docs/structure/problem_package.md`
   - notes: Local ingestion and validation logic exists (admin/CLI). No explicit AMQP consumer found to accept remote `dmoj.problem.package.submitted` messages — implement a consumer that invokes `create_problem_package`.

2. dmoj.problem.package.validated — JUDGE → DMOJ

   - implementation_exists: No (but easy to add)
   - files:
     - `judge/event_poster.py`
     - `judge/event_poster_amqp.py`
     - `judge/event_poster_ws.py`
   - notes: Emission can be implemented using the existing `event_poster` abstraction. Define a small payload schema and emit after validation.

3. dmoj.problem.image.build.request — DMOJ → JUDGE

   - implementation_exists: No
   - files:
     - `judge-docs/schemas/problem.schema.json` (build/dockerfile config)
     - sample problem packages referencing `Dockerfile.build`
   - notes: Build orchestration pieces referenced by config exist, but no consumer for an explicit build request event; implement a queue consumer to schedule image builds.

4. dmoj.problem.image.build.completed / .failed — JUDGE → DMOJ

   - implementation_exists: Partial
   - files:
     - `judge/event_poster.py`, `judge/event_poster_amqp.py`
     - various problem package build scripts and samples (no single build service file)
   - notes: A build-completed event can be published through `event_poster`; build pipeline code needs to publish it where builds are orchestrated.

5. dmoj.submission.submitted — DMOJ → JUDGE

   - implementation_exists: Partial/Yes
   - files:
     - `judge/bridge/judge_handler.py` (handles external packets / bridge logic)
     - `judge/judgeapi.py`
     - many submission models/views under `judge/` (submission lifecycle code)
   - notes: Submission model & processing exist. There is bridge code which processes incoming judge packets and updates submission state — check `judge_handler` for integration points to accept AMQP submission messages from DMOJ and enqueue evaluation.

6. judge.evaluation.started — JUDGE → DMOJ

   - implementation_exists: Partial
   - files:
     - `judge/event_poster.py`, `judge/event_poster_amqp.py`
     - evaluation runner code (various; not a single unified producer found)
   - notes: Use `event_poster` at the point evaluation is dequeued/started. No explicit existing event producers for this exact event name found.

7. judge.evaluation.progress — JUDGE → DMOJ (optional)

   - implementation_exists: No
   - files: none specifically for progress events
   - notes: Optional incremental updates; implement if long-running evaluations need visibility. Use `event_poster` to publish.

8. result.evaluation.completed — JUDGE → DMOJ

   - implementation_exists: Yes
   - files:
     - `judge-docs/schemas/result_event.schema.json` (canonical envelope)
     - `judge-docs/examples/result_event.json`
     - `judge/models/result.py`, migrations `0153_add_result_event_model.py`
   - notes: This event already has a schema, model support, and examples. Tie final evaluation code to publish this envelope via `event_poster` (if not already done in the evaluator).

9. result.evaluation.failed — JUDGE → DMOJ

   - implementation_exists: Partial
   - files:
     - `judge-docs/schemas/result_event.schema.json` (status supports `failed`)
     - `judge/models/result.py`
   - notes: Failure send-path is conceptually supported by the result schema; ensure the evaluator publishes `result.evaluation.failed` with error metadata when failures occur.

10. dmoj.artifact.uploaded — JUDGE → DMOJ

    - implementation_exists: Partial
    - files:
      - `judge/models/result.py` (artifacts JSONField)
      - `judge-docs/structure/container_internal.md` (artifact layout)
      - `judge-docs/schemas/result_event.schema.json` (artifacts in payload)
    - notes: Artifacts are stored and referenced in result events; a separate `artifact.uploaded` event is not present but can be added if you want fine-grained notifications for large artifacts.

11. dmoj.hooks.execute.request — JUDGE → Hook executor / DMOJ (optional)

    - implementation_exists: No
    - files:
      - `judge-docs/schemas/problem.schema.json` (`hooks_config`)
      - sample hooks in `samples/.../hooks/`
    - notes: Hooks are executed inside evaluation containers per the problem package spec. If you need external hook execution (e.g., call home or notify DMOJ to run something), add a hook-request event and a hook-response event. Otherwise hooks stay local.

12. judge.status / dmoj.heartbeat — JUDGE → orchestrator
    - implementation_exists: Partial
    - files:
      - `docker-compose.yml` (service healthchecks)
      - `judge-docs/schemas/problem.schema.json` (container `health_check` config)
    - notes: Container-level healthchecks exist, but no AMQP heartbeat/status event was found. Implement a periodic `judge.status` publisher if orchestration requires it (use non-persistent, low-volume messages).

---

Next steps (recommended, DMOJ↔JUDGE focus):

- Add/define consumer(s) for DMOJ→JUDGE messages:
  - `dmoj.problem.package.submitted` → consumer calls `create_problem_package`
  - `dmoj.problem.image.build.request` → consumer schedules build jobs
  - `dmoj.submission.submitted` → consumer enqueues evaluation (bridge/judge_handler is the likely place to integrate)
- Emit JUDGE→DMOJ events using `judge.event_poster` abstraction. Existing modules already import `event_poster` — wire producers in evaluator/build orchestrator points for:
  - `dmoj.problem.package.validated`, `dmoj.problem.image.build.completed/failed`, `judge.evaluation.started`, `result.evaluation.completed/failed`, `dmoj.artifact.uploaded`, `judge.status`.
- Create small JSON Schema files for submission/package/build/ artifact payloads and add under `judge-docs/schemas/` (consistent with `result_event.schema.json`). Include schema URI in AMQP headers when publishing.
- Implement idempotency and deduplication: consumers must dedupe on `submission_id`/`package_id` and track `event_id` where necessary.

If you want, I can now:

- generate the JSON Schema files for the DMOJ→JUDGE events and place them under `judge-docs/schemas/`, and/or
- add example producer calls in the evaluator/bridge locations (small patches) wiring `event_poster.post(...)`.

(Analysis completed for DMOJ ↔ JUDGE communications.)
