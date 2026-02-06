FROM python:3.11-slim-bullseye

USER root
WORKDIR /opt/oracle

RUN apt-get update && apt-get install -y libaio1 wget unzip && rm -rf /var/lib/apt/lists/*

COPY instantclient-basiclite-linuxx64.zip .
RUN unzip instantclient-basiclite-linuxx64.zip && rm -f instantclient-basiclite-linuxx64.zip
RUN echo /opt/oracle/instantclient_* > /etc/ld.so.conf.d/oracle-instantclient.conf && ldconfig
RUN cat /etc/ld.so.conf.d/oracle-instantclient.conf
ENV LD_LIBRARY_PATH="/opt/oracle/instantclient_23_26"
ENV ORACLE_HOME="/opt/oracle/instantclient_23_26"

RUN pip install oracledb

WORKDIR /app
COPY . .
CMD ["python", "ebs-dev.py"]
