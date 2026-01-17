from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

with DAG(
    dag_id="ebs_flyway_deploy",
    start_date=datetime(2024, 1, 1),
    schedule_interval=None,
    catchup=False,
    tags=["ebs", "flyway", "simulation"],
) as dag:
    run_flyway = BashOperator(
        task_id="run_flyway",
        bash_command="""
        flyway migrate \
          -baselineOnMigrate=true \
          -url=jdbc:postgresql://postgres:5432/demo \
          -user=demo \
          -password=demo \
          -locations=filesystem:/opt/airflow/flyway/sql
        """
    )
