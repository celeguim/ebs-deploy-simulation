FROM apache/airflow:2.9.1

USER root

ARG FLYWAY_VERSION=10.10.0

RUN curl -L https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}-linux-x64.tar.gz \
    | tar zx -C /opt && \
    chmod +x /opt/flyway-${FLYWAY_VERSION}/flyway && \
    ln -sf /opt/flyway-${FLYWAY_VERSION}/flyway /usr/local/bin/flyway && \
    chown airflow /opt/flyway-${FLYWAY_VERSION}/flyway

USER airflow
