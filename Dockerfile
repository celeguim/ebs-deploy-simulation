FROM apache/airflow:2.9.1

USER root
RUN apt-get update && apt-get install -y libaio1 && apt-get clean

USER airflow
# The /simple suffix is mandatory for --index-url
RUN PIP_CONSTRAINT="" pip install --no-cache-dir \
    --index-url https://pypi.org \
    --trusted-host pypi.org \
    --trusted-host files.pythonhosted.org \
    apache-airflow-providers-oracle python-oracledb
