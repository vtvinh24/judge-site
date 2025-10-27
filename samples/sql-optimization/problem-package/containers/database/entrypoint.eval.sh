#!/bin/bash
set -e

# Initialize PostgreSQL data directory if it doesn't exist
if [ ! -d "$PGDATA" ]; then
    echo "Initializing PostgreSQL data directory..."
    su-exec postgres initdb
fi

# Configure PostgreSQL for network access
echo "Configuring PostgreSQL..."
cat >> "$PGDATA/postgresql.conf" <<EOF
listen_addresses = '*'
max_connections = 100
EOF

cat >> "$PGDATA/pg_hba.conf" <<EOF
host all all 0.0.0.0/0 trust
local all all trust
EOF

# Start PostgreSQL in the background
echo "Starting PostgreSQL..."
su-exec postgres postgres &
PG_PID=$!

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
for i in {1..30}; do
    if pg_isready -U postgres >/dev/null 2>&1; then
        echo "PostgreSQL is ready!"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "PostgreSQL failed to start"
        exit 1
    fi
    sleep 2
done

# Create database and user
echo "Creating database and user..."
su-exec postgres createdb "$POSTGRES_DB" || true
su-exec postgres psql -c "CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD';" || true
su-exec postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;" || true

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

# Keep PostgreSQL running
echo "PostgreSQL is running and ready for connections"
wait $PG_PID