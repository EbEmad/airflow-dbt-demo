# ===============================
# Base image for Airflow targets
# ===============================
FROM apache/airflow:2.9.3-python3.11 AS airflow-base

USER root

# Keep image small and patched
RUN set -eux; \
    apt-get update; \
    echo 'msodbcsql18 msodbcsql/ACCEPT_EULA boolean true' | debconf-set-selections; \
    apt-get -y dist-upgrade; \
    apt-get install -y --no-install-recommends \
    curl \
    ; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*
# Common entrypoint for Airflow services
COPY scripts/Airflow.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Back to airflow user
USER airflow

# Python deps for Airflow (Airflow core is already in the base image)
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir --upgrade -r /tmp/requirements.txt

# Common directories
RUN mkdir -p /opt/airflow/dbt /opt/airflow/logs /opt/airflow/plugins

WORKDIR /opt/airflow


# Individual Airflow targets (webserver/scheduler/worker/flower use the same image)
FROM airflow-base AS airflow
ENTRYPOINT ["/entrypoint.sh"]

# ======================================
# Simple target: Airflow + DBT in one
# ======================================
FROM airflow-base AS airflow_simple

USER root
RUN set -eux; \
    apt-get update; \
    echo 'msodbcsql18 msodbcsql/ACCEPT_EULA boolean true' | debconf-set-selections; \
    apt-get -y dist-upgrade; \
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

ENTRYPOINT ["/entrypoint.sh"]

# ===============================
# DBT service target
FROM python:3.11-slim AS dbt

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

RUN set -eux; \
    apt-get update && \
    echo 'msodbcsql18 msodbcsql/ACCEPT_EULA boolean true' | debconf-set-selections && \
    apt-get -y dist-upgrade && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    wget \
    postgresql-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create dbt user
RUN useradd -m -s /bin/bash dbt

WORKDIR /opt/dbt

# Install Python packages
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    grep -E "^(dbt-|dbt-core)" /tmp/requirements.txt > /tmp/requirements-dbt-only.txt && \
    pip install --no-cache-dir --upgrade -r /tmp/requirements-dbt-only.txt

RUN chown -R dbt:dbt /opt/dbt

# Entrypoint for DBT
COPY scripts/dbt.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER dbt
ENV DBT_PROFILES_DIR=/opt/dbt/profiles \
    DBT_LOG_PATH=/opt/dbt/logs

ENTRYPOINT ["/entrypoint.sh"]