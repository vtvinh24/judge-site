# Updated DB Optimization Problem Package

This is an updated version of the database optimization problem package that follows the current FHCS Judge specification.

## Structure

```
db-optimization-updated/
├── config.json                    # Problem configuration following current schema
└── containers/                    # Container definitions
    ├── database/                  # PostgreSQL database container
    │   ├── Dockerfile.build       # Build stage Dockerfile
    │   ├── Dockerfile.eval        # Evaluation stage Dockerfile
    │   ├── entrypoint.eval.sh     # Evaluation entrypoint script
    │   ├── data/                  # Baseline SQL data files
    │   │   ├── baseline_Q1.sql
    │   │   ├── baseline_Q2.sql
    │   │   └── baseline_Q3.sql
    │   └── hooks/                 # Database lifecycle hooks
    │       └── pre/
    │           ├── 01_initialize.sh
    │           └── 02_migration.sh
    └── evaluator/                 # Query evaluation container
        ├── Dockerfile.build       # Build stage Dockerfile
        ├── Dockerfile.eval        # Evaluation stage Dockerfile
        ├── entrypoint.eval.sh     # Evaluation entrypoint script
        ├── submission/            # Template submission for build stage
        │   ├── migration.sql      # Template migration script
        │   ├── Q1.sql            # Template query 1
        │   ├── Q2.sql            # Template query 2
        │   └── Q3.sql            # Template query 3
        └── hooks/                 # Evaluation lifecycle hooks
            ├── pre/
            │   └── 01_setup.sh    # Setup evaluation environment
            └── post/
                ├── 01_test_queries.sh      # Test query correctness
                ├── 02_test_concurrency.sh  # Test concurrent performance
                ├── 03_evaluate_storage.sh  # Evaluate storage efficiency
                └── 04_test_performance.sh  # Test query performance
```

## Changes from Original

1. **Updated config.json**: Now follows the current problem schema with build/eval stage separation
2. **Container structure**: Moved containers to `containers/` directory with proper naming
3. **Multi-stage builds**: Separate Dockerfiles for build and evaluation stages
4. **Proper mounts**: Follows the `/workspace` layout specification
5. **Submission handling**: Evaluator container properly handles submission mounting
6. **Rubric outputs**: Updated to write to `/workspace/artifacts/rubrics/`
7. **Health checks**: Added proper health check configurations
8. **Port configuration**: Added port configuration for database container

## Submission Package

The corresponding submission package contains:

- `migration.sql` - Database schema optimization script
- `Q1.sql`, `Q2.sql`, `Q3.sql` - Optimized query implementations

## Running the Demo

```bash
node demo/run-updated-demo.js
```

This will:

1. Validate the problem package structure
2. Build the container images (build and eval stages)
3. Submit a test submission
4. Run the complete evaluation pipeline
5. Generate rubric scores and results
