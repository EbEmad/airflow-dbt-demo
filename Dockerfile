FROM apache/airflow:2.5.1 as airflow

COPY requirements.txt /requirements.txt
# Install Python dependencies
RUN pip install --no-cache-dir -r /requirements.txt

# Copy the entrypoint script
COPY  scripts/Airflow.sh /Airflow.sh

# Switch to the root user to change permissions
USER root
RUN chmod +x /Airflow.sh
RUN apt-get update && apt-get install -y git iputils-ping


# Switch back to the airflow user
USER airflow
ENV DBT_PROFILES_DIR=/opt/airflow/dbt/profiles


# Set the entrypoint to the entrypoint script
ENTRYPOINT ["/Airflow.sh"]


FROM python:3.11-slim AS dbt

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# System deps
RUN set -eux; \
    apt-get update; \
    apt-get -y upgrade; \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    wget \
    postgresql-client \
    ; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Create dbt user
RUN useradd -m -s /bin/bash dbt

# Install pytz explicitly
RUN pip install --no-cache-dir pytz

WORKDIR /opt/dbt

# Install Python packages
COPY requirements-dbt.txt /tmp/requirements.txt
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    # Install only dbt-related deps for dbt stage
    grep -E "^(dbt-|dbt-core)" /tmp/requirements.txt > /tmp/requirements-dbt-only.txt && \
    pip install --no-cache-dir -r /tmp/requirements-dbt-only.txt

# Paths
RUN mkdir -p /opt/dbt/profiles /opt/dbt/logs /opt/dbt/target && \
    chown -R dbt:dbt /opt/dbt

# Entrypoint for DBT
COPY scripts/dbt.sh /dbt.sh
RUN chmod +x /dbt.sh
USER dbt

ENV DBT_PROFILES_DIR=/opt/dbt/profiles \
    DBT_LOG_PATH=/opt/dbt/logs


ENTRYPOINT ["/dbt.sh"]