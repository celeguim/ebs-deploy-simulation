FROM python:3.11-slim-bullseye

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y libaio1 wget unzip && rm -rf /var/lib/apt/lists/*

# Use the direct "Basic Light" link which doesn't require a cookie header
RUN mkdir -p /opt/oracle && cd /opt/oracle && \
    wget --no-check-certificate https://download.oracle.com/otn_software/linux/instantclient/instantclient-basiclite-linuxx64.zip && \
    unzip instantclient-basiclite-linuxx64.zip && \
    rm -f instantclient-basiclite-linuxx64.zip

# Configure the library path (The folder unzips as 'instantclient_XX_X')
RUN echo /opt/oracle/instantclient_* > /etc/ld.so.conf.d/oracle-instantclient.conf && ldconfig

RUN pip install oracledb

COPY . .

CMD ["python", "ebs-dev.py"]
