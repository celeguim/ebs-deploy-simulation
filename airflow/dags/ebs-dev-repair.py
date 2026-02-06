from airflow.operators.bash import BashOperator
# from airflow.providers.standard.operators.bash import BashOperator
from airflow import DAG
from datetime import datetime

with DAG(
        dag_id="ebs_dev_repair",
        start_date=datetime(2026, 1, 1),
        schedule=None,
        catchup=False,
) as dag:
    # DEBUG
    run_flyway_debug = BashOperator(
        task_id="repair",
        bash_command="""
        set -euxo pipefail

        echo "=== Flyway version ==="
        flyway -v

        echo "=== Listing migrations directory ==="
        ls -lah /opt/airflow/flyway/sql-prd

        echo "=== Running Flyway migrate ==="

        echo LD_LIBRARY_PATH $LD_LIBRARY_PATH
        export JAVA_OPTS="-Djava.library.path=/opt/oracle/instantclient_21_21"

        flyway -X repair \
          -url=jdbc:oracle:oci:@//ocifra2600-umjv1-scan.findbpriad2.financevcn.oraclevcn.com:1521/DEV \
          -user=apps \
          -password=qp#h8EM8sgv8Ax8# \
          -locations=filesystem:/opt/airflow/flyway/sql-prd

        """
    )
