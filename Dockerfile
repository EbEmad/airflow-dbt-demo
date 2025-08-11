# Base image for Airflow targets
FROM apache/airflow:2.9.3-python3.11 AS airflow-base
USER root
# Keep image small and patched
RUN set -eux; \
    apt-get update; \
    apt-get -y upgrade; \
    apt-get install -y --no-install-recommends \
    curl \
    ; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*
# Back to airflow user
USER airflow
# Python deps for Airflow (Airflow core is already in the base image)
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r /tmp/requirements.txt
# Common directories
RUN mkdir -p /opt/airflow/dbt /opt/airflow/logs /opt/airflow/plugins   /opt/airflow/dags
WORKDIR /opt/airflow
# Common entrypoint for Airflow services
COPY scripts/Airflow.sh /Airflow.sh
RUN chmod +x /Airflow.sh



# Individual Airflow targets (webserver/scheduler/worker/flower use the same image)
FROM airflow-base AS airflow
ENTRYPOINT [ "/Airflow.sh" ]


# Simple target: Airflow + DBT in one
FROM airflow-base AS airflow_simple
USER root
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    postgresql-client \
    ; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*
USER airflow
# Install DBT and common adapters
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r /tmp/requirements.txt
ENTRYPOINT ["/Airflow.sh"]

# DBT service target
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
WORKDIR /opt/dbt
# Install Python packages
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    # Install only dbt-related deps for dbt stage
    grep -E "^(dbt-|dbt-core)" /tmp/requirements.txt > /tmp/requirements-dbt-only.txt && \
    pip install --no-cache-dir -r /tmp/requirements-dbt-only.txt
# Paths
RUN mkdir -p /opt/dbt/profiles /opt/dbt/logs /opt/dbt/target && \
    chown -R dbt:dbt /opt/dbt
USER dbt
ENV DBT_PROFILES_DIR=/opt/dbt/profiles \
    DBT_LOG_PATH=/opt/dbt/logs

# Entrypoint for DBT
COPY scripts/dbt.sh /dbt.sh
ENTRYPOINT ["/dbt.sh"]

