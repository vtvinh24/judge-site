#!/bin/bash
set -e

echo "Starting evaluator container..."

# Create ready signal
touch /workspace/ready

# Wait for database to be ready
echo "Waiting for database to be ready..."
until pg_isready -h database -U judge -d hackathon_db; do
  echo "Database not ready, waiting..."
  sleep 2
done

echo "Database is ready!"

# Execute pre hooks if they exist
if [ -d "/workspace/hooks/pre" ]; then
  echo "Executing pre hooks..."
  for hook in /workspace/hooks/pre/*.sh; do
    if [ -f "$hook" ]; then
      echo "Running $hook"
      bash "$hook" || echo "Hook $hook failed"
    fi
  done
fi

# Copy submission to tmp directory for evaluation
if [ -d "/workspace/submission" ]; then
  echo "Copying submission to tmp directory..."
  cp -r /workspace/submission/* /workspace/tmp/ || true
fi

# Execute post hooks if they exist
if [ -d "/workspace/hooks/post" ]; then
  echo "Executing post hooks..."
  for hook in /workspace/hooks/post/*.sh; do
    if [ -f "$hook" ]; then
      echo "Running $hook"
      bash "$hook" || echo "Hook $hook failed"
    fi
  done
fi

echo "Evaluation complete, keeping container alive..."
sleep infinity