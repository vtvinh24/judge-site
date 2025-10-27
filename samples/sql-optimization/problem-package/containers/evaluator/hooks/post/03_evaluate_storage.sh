#!/bin/bash
set -e

echo "[POST] Evaluating storage efficiency"

# Get current database size
CURRENT_SIZE=$(psql -h database -U judge -d hackathon_db -t -c "SELECT pg_database_size('hackathon_db');" 2>/dev/null | tr -d '[:space:]' || echo "0")

# Read initial size
if [ -f "/workspace/artifacts/logs/initial_size.txt" ]; then
    INITIAL_SIZE=$(cat /workspace/artifacts/logs/initial_size.txt)
else
    echo "[ERROR] Initial size file not found!"
    INITIAL_SIZE=0
fi

EXTRA_SIZE=$((CURRENT_SIZE - INITIAL_SIZE))

echo "[TEST] Initial dataset: $INITIAL_SIZE bytes"
echo "[TEST] Current size: $CURRENT_SIZE bytes"
echo "[TEST] Additional storage: $EXTRA_SIZE bytes"

# Calculate storage efficiency score
# score_s = clamp(1 - (extra_storage / (0.3 * base_data_size)), 0, 1)
if [ "$INITIAL_SIZE" -gt 0 ]; then
    target_extra=$(awk "BEGIN {printf \"%.0f\", $INITIAL_SIZE * 0.3}")
    if [ "$target_extra" -gt 0 ]; then
        storage_ratio=$(awk "BEGIN {printf \"%.4f\", $EXTRA_SIZE / $target_extra}")
        storage_score=$(awk "BEGIN {score = 1 - $storage_ratio; if (score < 0) score = 0; if (score > 1) score = 1; printf \"%.4f\", score}")
        extra_percentage=$(awk "BEGIN {printf \"%.2f\", $EXTRA_SIZE * 100 / $INITIAL_SIZE}")
    else
        storage_score=1
        extra_percentage=0
    fi
else
    storage_score=0
    extra_percentage=0
fi

final_score=$(awk "BEGIN {printf \"%.2f\", $storage_score * 10}")

cat > /workspace/artifacts/rubrics/rubric_efficiency.json <<EOF
{
  "rubric_id": "efficiency",
  "rubric_type": "database_integrity",
  "max_score": 10,
  "score": $final_score,
  "status": "DONE",
  "details": {
    "initial_size_bytes": $INITIAL_SIZE,
    "current_size_bytes": $CURRENT_SIZE,
    "extra_storage_bytes": $EXTRA_SIZE,
    "extra_storage_percentage": $extra_percentage,
    "target_percentage": 30
  },
  "message": "Storage: ${extra_percentage}% additional (target: ≤30%)"
}
EOF

echo "[POST] Storage efficiency evaluation complete"