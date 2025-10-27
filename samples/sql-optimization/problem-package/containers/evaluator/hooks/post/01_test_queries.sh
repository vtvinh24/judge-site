#!/bin/bash
set -e

echo "[POST] Testing query correctness and performance"

# Apply migration first
echo "[TEST] Applying migration..."
psql -h database -U judge -d hackathon_db -f "/workspace/tmp/migration.sql" > /workspace/artifacts/logs/migration.log 2>&1
MIGRATION_EXIT=$?

if [ $MIGRATION_EXIT -ne 0 ]; then
    echo "[ERROR] Migration failed!"
    cat > /workspace/artifacts/rubrics/rubric_correctness.json <<EOF
{
  "rubric_id": "correctness",
  "rubric_type": "test_cases",
  "max_score": 50,
  "score": 0,
  "status": "DONE",
  "details": {
    "error": "Migration failed"
  },
  "message": "Migration script failed to execute"
}
EOF
    exit 1
fi

# Function to run query and measure time
run_query() {
    local query_name=$1
    local query_file=$2
    
    echo "[TEST] Running $query_name..."
    
    # Warm-up run
    psql -h database -U judge -d hackathon_db -f "$query_file" > /dev/null 2>&1 || true
    
    # Timed runs (2 iterations)
    local total_time=0
    local runs=0
    local success=true
    
    for i in 1 2; do
        START=$(date +%s%3N)
        OUTPUT=$(psql -h database -U judge -d hackathon_db -f "$query_file" 2>&1)
        EXIT_CODE=$?
        END=$(date +%s%3N)
        TIME_MS=$((END - START))
        
        if [ $EXIT_CODE -ne 0 ]; then
            echo "[FAIL] $query_name failed with exit code $EXIT_CODE"
            success=false
            break
        fi
        
        # Check if query timed out (>5 seconds)
        if [ $TIME_MS -gt 5000 ]; then
            echo "[FAIL] $query_name timed out (${TIME_MS}ms > 5000ms)"
            success=false
            break
        fi
        
        total_time=$((total_time + TIME_MS))
        runs=$((runs + 1))
        
        echo "[TEST] $query_name run $i: ${TIME_MS}ms"
    done
    
    if [ "$success" = true ] && [ $runs -gt 0 ]; then
        MEDIAN_TIME=$((total_time / runs))
        echo "[TEST] $query_name median time: ${MEDIAN_TIME}ms"
        echo "$query_name|$MEDIAN_TIME|true"
    else
        echo "$query_name|5000|false"
    fi
}

# Run queries and collect results
echo "" > /workspace/tmp/query_results.txt
run_query "Q1" "/workspace/tmp/Q1.sql" >> /workspace/tmp/query_results.txt
run_query "Q2" "/workspace/tmp/Q2.sql" >> /workspace/tmp/query_results.txt
run_query "Q3" "/workspace/tmp/Q3.sql" >> /workspace/tmp/query_results.txt

# Process correctness results
total_queries=3
passed_queries=0

while IFS='|' read -r query_name time_ms success; do
    if [ "$success" = "true" ]; then
        passed_queries=$((passed_queries + 1))
    fi
done < /workspace/tmp/query_results.txt

correctness_score=$(awk "BEGIN {printf \"%.2f\", ($passed_queries * 100 / $total_queries) * 0.5}")

# Generate correctness rubric
cat > /workspace/artifacts/rubrics/rubric_correctness.json <<EOF
{
  "rubric_id": "correctness",
  "rubric_type": "test_cases",
  "max_score": 50,
  "score": $correctness_score,
  "status": "DONE",
  "details": {
    "total_queries": $total_queries,
    "passed_queries": $passed_queries,
    "failed_queries": $((total_queries - passed_queries))
  },
  "message": "Query correctness: $passed_queries/$total_queries queries passed"
}
EOF

echo "[POST] Query testing complete"