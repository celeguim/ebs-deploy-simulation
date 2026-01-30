from airflow.decorators import dag, task
from airflow.providers.oracle.hooks.oracle import OracleHook
from datetime import datetime
# import pandas as pd

@dag(
    dag_id="ebs_prd_deploy",
    schedule=None,
    start_date=datetime(2026, 1, 1),
    catchup=False,
)

def extract_from_ebs_and_load():
    @task()
    def jdbc_extract():
        try:
            # The hook automatically uses thick_mode=True if configured in the connection 'Extra'
            hook = OracleHook(oracle_conn_id="oracle_ebs_conn")

            # Example SQL query to extract data from an EBS table (replace with actual query)
            sql = "SELECT to_char(SYSDATE, 'yyyy-MM-dd HH:MI:SS') FROM dual"

            df = hook.get_pandas_df(sql)
            print(f"Extracted {len(df)} records.")

            # Process the data as needed (e.g., write to another system, save to file)
            # Example: convert to dictionary for XCom push
            return df.to_dict('records')

        except Exception as e:
            print("Data extract error: " + str(e))
            raise

    extract_task = jdbc_extract()

extract_from_ebs_and_load()
