from airflow.operators.bash import BashOperator
# from airflow.providers.standard.operators.bash import BashOperator
from airflow import DAG
from datetime import datetime

with DAG(
        dag_id="oracle_prd_deploy",
        start_date=datetime(2026, 1, 1),
        schedule=None,
        catchup=False,
) as dag:
    # DEBUG
    run_flyway_debug = BashOperator(
        task_id="run_flyway_prd",
        bash_command="""
        set -euxo pipefail

        echo "=== Flyway version ==="
        flyway -v

        echo "=== Listing migrations directory ==="
        ls -lah /opt/airflow/flyway/sql-prd

        echo "=== Running Flyway migrate ==="

        flyway -X migrate \
          -baselineOnMigrate=true \
          -url=jdbc:oracle:thin:@//oracle:1521/xe \
          -user=celeghin \
          -password=celeghin \
          -locations=filesystem:/opt/airflow/flyway/sql-prd
        """
    )
