#!/bin/bash
set -e

echo "[PRE] Setting up submission evaluation environment"

# Ensure artifacts directories exist
mkdir -p /workspace/artifacts/logs /workspace/artifacts/rubrics

# Check if required files exist in submission
REQUIRED_FILES=("migration.sql" "Q1.sql" "Q2.sql" "Q3.sql")
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "/workspace/tmp/$file" ]; then
        echo "[ERROR] $file not found in submission!"
        echo "{\"error\": \"Missing required file: $file\"}" > /workspace/artifacts/rubrics/rubric_correctness.json
        exit 1
    fi
done

echo "[PRE] All required files present"

# Create query runner helper
cat > /workspace/run_query.sh <<'SCRIPT'
#!/bin/bash
QUERY_FILE=$1
OUTPUT_FILE=$2

START=$(date +%s%3N)
psql -h database -U judge -d hackathon_db -f "$QUERY_FILE" > "$OUTPUT_FILE" 2>&1
EXIT_CODE=$?
END=$(date +%s%3N)
TIME_MS=$((END - START))

echo "$TIME_MS|$EXIT_CODE"
SCRIPT

chmod +x /workspace/run_query.sh

echo "[PRE] Setup complete"