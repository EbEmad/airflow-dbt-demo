from datetime import datetime,timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

default_args={
    'onwer': 'Ebrahim Emad',
    'depends_on_past': False,
    'start_date': datetime(2025,8,16),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries':1,
    'retry_delay': timedelta(minutes=5),
}

dag=DAG(
    'dbt_pipeline',
    default_args=default_args,
    description='A DAG to run DBT transformations',
    schedule_interval=timedelta(hours=1),
    catchup=False,
    tags=['dbt', 'data-engineering'],
)

install_deps=BashOperator(
    task_id='install_dbt_deps',
    bash_command='cd /opt/airflow/dbt && dbt deps',
    dag=dag,
)
debug_connection=BashOperator(
    task_id='debug_connection',
    bash_command='cd /opt/airflow/dbt && dbt debug',
    dag=dag,
)
run_models = BashOperator(
    task_id='run_dbt_models',
    bash_command='cd /opt/airflow/dbt && dbt run',
    dag=dag,
)

install_deps >> debug_connection  >> run_models 