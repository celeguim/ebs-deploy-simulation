from datetime import datetime
from airflow.operators.bash import BashOperator
from airflow import DAG

with DAG(
        dag_id="ebs_flyway_deploy",
        start_date=datetime(2024, 1, 1),
        schedule_interval=None,
        catchup=False,
) as dag:
    run_flyway = BashOperator(
        task_id="run_flyway",
        bash_command="""
        docker run --rm \
          --network ebs-simulation_default \
          -v $(pwd)/flyway/sql:/flyway/sql \
          flyway/flyway:10 \
          -url=jdbc:postgresql://postgres:5432/demo \
          -user=demo \
          -password=demo \
          migrate
        """
    )
