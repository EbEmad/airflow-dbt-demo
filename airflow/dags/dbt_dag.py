from datetime import datetime, timedelta
from pathlib import Path

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.empty import EmptyOperator

from dbt_airflow.core.config import DbtAirflowConfig, DbtProjectConfig, DbtProfileConfig
from dbt_airflow.core.task_group import DbtTaskGroup
from dbt_airflow.core.task import ExtraTask
from dbt_airflow.operators.execution import ExecutionOperator
from airflow.operators.bash import BashOperator

default_args={
    'owner': 'Ebrahim Emad',
    'depends_on_past': False,
    'start_date': datetime(2025,8,17),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries':1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id='test_dag',
    start_date=datetime(2025, 8, 17),
    catchup=False,
    tags=['staging','marts'],
    default_args={
        'owner': 'airflow',
        'retries': 1,
        'retry_delay': timedelta(minutes=2),
    },
) as dag:
    debug_connection = BashOperator(
    task_id='debug_connection',
    bash_command='cd /opt/airflow/dbt && dbt debug',
    dag=dag,
        )
    tg=DbtTaskGroup(
        group_id='dbt_task_group',
        dbt_project_config=DbtProjectConfig(
            project_path=Path('/opt/airflow/dbt'),
            manifest_path=Path('/opt/airflow/dbt/target/manifest.json')
        ),
        dbt_profile_config=DbtProfileConfig(
            profiles_path=Path('/opt/airflow/dbt/profiles'),
            target='dev',
        )
    )

    debug_connection >> tg