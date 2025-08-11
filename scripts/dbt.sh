#!/bin/bash
set -e

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
while ! pg_isready -h postgres -p 5432 -U airflow;do
    sleep 2
done

echo "PostgreSQL is ready!"

# Initialize DBT project if it doesn't exist
if [ ! -f /opt/dbt/dbt_project.yml]; then 
    echo "Initializing DBT project...
    dbt init my_dbt_project --profile-dir /opt/dbt
    echo "DBT project initialized."
fi

# Run the requested command
exec "$@"