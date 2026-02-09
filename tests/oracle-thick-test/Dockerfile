FROM python:3.11-slim-bullseye

USER root
WORKDIR /opt/oracle

RUN apt-get update && apt-get install -y libaio1 wget unzip && rm -rf /var/lib/apt/lists/*

# COMPATIBLE VERSION 21
COPY instantclient-basic-linux.x64-21.21.0.0.0dbru.zip .
RUN unzip instantclient-basic-linux.x64-21.21.0.0.0dbru.zip && rm -f instantclient-basic-linux.x64-21.21.0.0.0dbru.zip
RUN echo /opt/oracle/instantclient_* > /etc/ld.so.conf.d/oracle-instantclient.conf && ldconfig
RUN cat /etc/ld.so.conf.d/oracle-instantclient.conf
ENV LD_LIBRARY_PATH="/opt/oracle/instantclient_21_21"
ENV ORACLE_HOME="/opt/oracle/instantclient_21_21"

RUN pip install oracledb

WORKDIR /app
COPY . .
CMD ["python", "ebs-dev.py"]
