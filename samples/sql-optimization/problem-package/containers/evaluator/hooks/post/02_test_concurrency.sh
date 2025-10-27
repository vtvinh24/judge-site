#!/bin/bash
set -e

echo "[POST] Testing concurrent load performance"

# Create concurrent query runner
cat > /workspace/tmp/concurrent_query.sh <<'SCRIPT'
#!/bin/bash
count=0
start_time=$(date +%s)
end_time=$((start_time + 30))

while [ $(date +%s) -lt $end_time ]; do
    psql -h database -U judge -d hackathon_db -f /workspace/tmp/Q1.sql > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        count=$((count + 1))
    fi
done

echo $count
SCRIPT

chmod +x /workspace/tmp/concurrent_query.sh

# Run 5 clients in parallel for 30 seconds (reduced for testing)
echo "[TEST] Running 5 concurrent clients for 30 seconds..."
total_queries=0

for i in {1..5}; do
    /workspace/tmp/concurrent_query.sh > /workspace/tmp/client_${i}.count &
done

# Wait for all clients
wait

# Collect results
for i in {1..5}; do
    if [ -f /workspace/tmp/client_${i}.count ]; then
        client_count=$(cat /workspace/tmp/client_${i}.count)
        total_queries=$((total_queries + client_count))
    fi
done

# Calculate throughput (queries per second)
throughput=$(awk "BEGIN {printf \"%.2f\", $total_queries / 30}")

echo "[TEST] Total queries: $total_queries"
echo "[TEST] Throughput: $throughput queries/second"

# Score: target = 5 qps (reduced target)
target_throughput=5
if [ "$total_queries" -gt 0 ]; then
    concurrency_score=$(awk "BEGIN {score = $throughput / $target_throughput; if (score > 1) score = 1; printf \"%.4f\", score}")
else
    concurrency_score=0
fi

final_score=$(awk "BEGIN {printf \"%.2f\", $concurrency_score * 10}")

cat > /workspace/artifacts/rubrics/rubric_concurrency.json <<EOF
{
  "rubric_id": "concurrency",
  "rubric_type": "performance",
  "max_score": 10,
  "score": $final_score,
  "status": "DONE",
  "details": {
    "total_queries": $total_queries,
    "duration_seconds": 30,
    "concurrent_clients": 5,
    "throughput_qps": $throughput,
    "target_qps": $target_throughput
  },
  "message": "Concurrency: $throughput qps (target: $target_throughput)"
}
EOF

echo "[POST] Concurrency test complete"