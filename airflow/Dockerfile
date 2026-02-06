###############################
# Build Stage
FROM apache/airflow:2.9.1 AS airflow-build
# ARG FLYWAY_VERSION=11.8.0
ARG FLYWAY_VERSION=12.0.0
ARG PYTHON_VERSION=3.12.3

RUN whoami
# airflow

RUN pwd
# /opt/airflow

RUN cat /etc/os-release
# PRETTY_NAME="Debian GNU/Linux 12 (bookworm)"

RUN whereis python3
RUN whereis pip
RUN echo "PATH before: ${PATH}"
ENV PATH="/home/airflow/.local/bin:${PATH}"
RUN python3 -V
RUN python3 -m pip install --upgrade pip
COPY constraints-3.12.txt /tmp/constraints.txt
RUN echo "pip silent install .."
RUN python3 -m pip install --no-cache-dir \
    apache-airflow-providers-oracle \
    --constraint /tmp/constraints.txt
#RUN /usr/bin/env -u AIRFLOW_CONSTRAINTS_LOCATION \
#                 -u AIRFLOW_CONSTRAINTS_REFERENCE \
#                 pip install --no-cache-dir \
#                 apache-airflow-providers-oracle oracledb >/dev/null
ENV PATH="/home/airflow/.local/bin:${PATH}"
RUN echo "PATH after: ${PATH}"
RUN pip show oracledb
RUN pip show apache-airflow-providers-oracle
RUN whoami
RUN pwd
RUN ls -lta

USER root
WORKDIR /opt/oracle

# oracle thick client dependencies
RUN apt-get update && apt-get install -y libaio1 wget unzip && apt-get clean && rm -rf /var/lib/apt/lists/*

# INCOMPATIBLE VERSION 23
#COPY instantclient-basiclite-linuxx64.zip .
#RUN unzip instantclient-basiclite-linuxx64.zip && rm -f instantclient-basiclite-linuxx64.zip
#RUN echo /opt/oracle/instantclient_* > /etc/ld.so.conf.d/oracle-instantclient.conf && ldconfig
#RUN cat /etc/ld.so.conf.d/oracle-instantclient.conf
#ENV LD_LIBRARY_PATH="/opt/oracle/instantclient_23_26"
#ENV ORACLE_HOME="/opt/oracle/instantclient_23_26"

# COMPATIBLE VERSION 21
COPY instantclient-basic-linux.x64-21.21.0.0.0dbru.zip .
RUN unzip instantclient-basic-linux.x64-21.21.0.0.0dbru.zip && rm -f instantclient-basic-linux.x64-21.21.0.0.0dbru.zip
RUN echo /opt/oracle/instantclient_* > /etc/ld.so.conf.d/oracle-instantclient.conf && ldconfig
RUN cat /etc/ld.so.conf.d/oracle-instantclient.conf
ENV LD_LIBRARY_PATH="/opt/oracle/instantclient_21_21"
ENV ORACLE_HOME="/opt/oracle/instantclient_21_21"

USER airflow
WORKDIR /home/airflow
RUN mkdir -p /opt/airflow/flyway/sql-dev
RUN mkdir -p /opt/airflow/flyway/sql-prd

# flyway dependencies
WORKDIR /opt/flyway-${FLYWAY_VERSION}
RUN ls -lta
COPY flyway-commandline-${FLYWAY_VERSION}-linux-x64.tar.gz .
RUN tar zxvf flyway-commandline-${FLYWAY_VERSION}-linux-x64.tar.gz -C /opt
RUN rm -f /opt/flyway-${FLYWAY_VERSION}/flyway-commandline-linux-x64.tar.gz
USER root
RUN chmod +x /opt/flyway-${FLYWAY_VERSION}/flyway
RUN ln -sf /opt/flyway-${FLYWAY_VERSION}/flyway /usr/local/bin/flyway
RUN chown airflow /opt/flyway-${FLYWAY_VERSION}/flyway
# ojdbc compatibility
RUN rm /opt/flyway-12.0.0/drivers/ojdbc11-21.18.0.0.jar
RUN cp /opt/oracle/instantclient_21_21/ojdbc11.jar /opt/flyway-12.0.0/drivers/ojdbc11-21.21.0.0.jar
RUN chown airflow /opt/flyway-12.0.0/drivers/ojdbc11-21.21.0.0.jar

###############################
# Runtime Stage
FROM airflow-build
WORKDIR /opt/airflow
USER airflow
