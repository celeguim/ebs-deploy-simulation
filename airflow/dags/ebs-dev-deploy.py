from airflow.operators.bash import BashOperator
# from airflow.providers.standard.operators.bash import BashOperator
from airflow import DAG
from datetime import datetime
from airflow.hooks.base import BaseHook

with DAG(
        dag_id="ebs_dev_deploy",
        start_date=datetime(2026, 1, 1),
        schedule=None,
        catchup=False,
) as dag:
    # DEBUG

    conn = BaseHook.get_connection("ebs_dev_conn")

    oracle_host = conn.host
    oracle_port = conn.port
    oracle_service = conn.schema
    oracle_user = conn.login
    oracle_password = conn.password

    run_flyway_debug = BashOperator(
        task_id="deploy",
        bash_command="""
        set -euxo pipefail

        echo "=== Flyway version ==="
        flyway -v

        echo "=== Listing migrations directory ==="
        ls -lah /opt/airflow/flyway/sql-prd

        echo "=== Running Flyway migrate ==="

        echo LD_LIBRARY_PATH $LD_LIBRARY_PATH
        export JAVA_OPTS="-Djava.library.path=/opt/oracle/instantclient_21_21"

        flyway -X migrate \
          -baselineOnMigrate=true \
          -url=jdbc:oracle:oci:@//{oracle_host}:{oracle_port}/{oracle_service} \
          -user={oracle_user} \
          -password={oracle_password} \
          -locations=filesystem:/opt/airflow/flyway/sql-prd

        """
    )
