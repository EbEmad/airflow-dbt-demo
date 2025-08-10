#!/bin/bash
set -e
# Initialize/Migrate Airflow database
airflow db migrate || airflow db init

# Create admin user if not exists

if ! airflow users list | grep -q "admin"; then
    airflow users create \
        --username admin \
        --firstname Ebrahim \
        --lastname Emad \
        --role Admin \
        --email admin@example.com
        --password admin
fi

# Start the requested service
exec airflow "$@"