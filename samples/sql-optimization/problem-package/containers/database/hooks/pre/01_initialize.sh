#!/bin/bash
set -eu

echo "[PRE] Initializing database workspace"

# Ensure workspace directories exist
mkdir -p /workspace/tmp /workspace/artifacts/logs /workspace/artifacts/rubrics

# Set proper ownership
chown -R postgres:postgres /workspace/tmp /workspace/artifacts 2>/dev/null || true

echo "[PRE] Database workspace initialization complete"