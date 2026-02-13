from airflow.operators.bash import BashOperator
# from airflow.providers.standard.operators.bash import BashOperator
from airflow import DAG
from datetime import datetime
from airflow.hooks.base import BaseHook

with DAG(
        dag_id="ebs_dev_repair",
        start_date=datetime(2026, 1, 1),
        schedule=None,
        catchup=False,
) as dag:
    # DEBUG

    conn = BaseHook.get_connection("ebs_dev_conn")

    oracle_host = conn.host
    oracle_port = conn.port
    oracle_service = conn.extra_dejson.get('service_name')
    oracle_user = conn.login
    oracle_password = conn.password

    run_flyway_debug = BashOperator(
        task_id="repair",

        params={
            "oracle_host": oracle_host,
            "oracle_port": oracle_port,
            "oracle_service": oracle_service,
            "oracle_user": oracle_user,
            "oracle_password": oracle_password
        },

        bash_command="""
        set -euxo pipefail

        echo "=== Flyway version ==="
        flyway -v

        echo "=== Listing migrations directory ==="
        ls -lah /opt/airflow/flyway/sql

        echo "=== Running Flyway repair ==="

        echo LD_LIBRARY_PATH $LD_LIBRARY_PATH
        export JAVA_OPTS="-Djava.library.path=/opt/oracle/instantclient_21_21"

        flyway -X repair \
          -url=jdbc:oracle:oci:@//{{ params.oracle_host }}:{{ params.oracle_port }}/{{ params.oracle_service }} \
          -user={{ params.oracle_user }} \
          -password={{ params.oracle_password }} \
          -locations=filesystem:/opt/airflow/flyway/sql

        """
    )
