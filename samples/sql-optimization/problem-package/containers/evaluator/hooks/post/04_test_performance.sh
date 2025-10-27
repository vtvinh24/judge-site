#!/bin/bash
set -e

echo "[POST] Testing query performance"

# Read performance data from query testing results
if [ ! -f "/workspace/tmp/query_results.txt" ]; then
    echo "[ERROR] Query results not found!"
    cat > /workspace/artifacts/rubrics/rubric_performance.json <<EOF
{
  "rubric_id": "performance",
  "rubric_type": "performance",
  "max_score": 30,
  "score": 0,
  "status": "DONE",
  "details": {
    "error": "Query results not found"
  },
  "message": "Performance test failed - no query results"
}
EOF
    exit 1
fi

# Process latency results (target: 2000ms)
latency_score=0
query_count=0

while IFS='|' read -r query_name time_ms success; do
    if [ "$success" = "true" ]; then
        query_count=$((query_count + 1))
        # score_q = clamp((2000 / median_time_ms), 0, 1)
        if [ "$time_ms" -gt 0 ]; then
            # Calculate score using awk for floating point
            query_score=$(awk "BEGIN {score = 2000 / $time_ms; if (score > 1) score = 1; printf \"%.4f\", score}")
            latency_score=$(awk "BEGIN {printf \"%.4f\", $latency_score + $query_score}")
        fi
    fi
done < /workspace/tmp/query_results.txt

if [ $query_count -gt 0 ]; then
    avg_latency_score=$(awk "BEGIN {printf \"%.4f\", $latency_score / $query_count}")
    final_latency_score=$(awk "BEGIN {printf \"%.2f\", $avg_latency_score * 30}")
else
    avg_latency_score=0
    final_latency_score=0
fi

cat > /workspace/artifacts/rubrics/rubric_performance.json <<EOF
{
  "rubric_id": "performance",
  "rubric_type": "performance",
  "max_score": 30,
  "score": $final_latency_score,
  "status": "DONE",
  "details": {
    "queries_tested": $query_count,
    "target_ms": 2000,
    "timeout_ms": 5000,
    "avg_score": $avg_latency_score
  },
  "message": "Query performance: average score $avg_latency_score"
}
EOF

echo "[POST] Performance test complete"