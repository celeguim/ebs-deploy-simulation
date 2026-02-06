from airflow.operators.bash import BashOperator
# from airflow.providers.standard.operators.bash import BashOperator
from airflow import DAG
from datetime import datetime

with DAG(
        dag_id="mysql_dev_deploy",
        start_date=datetime(2026, 1, 1),
        schedule=None,
        catchup=False,
) as dag:
    # run_flyway = BashOperator(
    #     task_id="run_flyway",
    #     bash_command="""
    #     flyway migrate \
    #       -baselineOnMigrate=true \
    #       -url=jdbc:mysql://mysql:3306/demo \
    #       -user=demo \
    #       -password=demo \
    #       -locations=filesystem:/opt/airflow/flyway/sql
    #     """
    # )

    # DEBUG
    run_flyway_debug = BashOperator(
        task_id="run_flyway_debug",
        bash_command="""
        set -euxo pipefail

        echo "=== Flyway version ==="
        flyway -v

        echo "=== Listing migrations directory ==="
        ls -lah /opt/airflow/flyway/sql-dev

        echo "=== Running Flyway migrate ==="

        flyway -X migrate \
          -baselineOnMigrate=true \
          -url=jdbc:mysql://mysql:3306/demo \
          -user=demo \
          -password=demo \
          -locations=filesystem:/opt/airflow/flyway/sql-dev
        """
    )
