#!/bin/bash
set -e

# Initialize DBT project if it doesn't exist
if [ ! -f /opt/dbt/dbt_project.yml ]; then
    echo "Initializing DBT project..."
    dbt init my_dbt_project --profiles-dir /opt/dbt
    echo "DBT project initialized."
fi

# Run the requested command
exec "$@"
