# ebs-deploy-simulation

## mysql .env : example
MYSQL_HOST=mysql
MYSQL_PORT=3306
MYSQL_DATABASE=demo
MYSQL_USER=demo
MYSQL_PASSWORD=demo
MYSQL_ROOT_PASSWORD=root

## db initialization
docker exec -it airflow airflow db migrate
docker exec -it airflow flyway -X migrate   -baselineOnMigrate=true   -url=jdbc:mysql://mysql:3306/demo   -user=demo   -password=demo   -locations=filesystem:/opt/airflow/flyway/sql
docker exec -it airflow flyway -X repair -url=jdbc:mysql://mysql:3306/demo   -user=demo   -password=demo  

## create user admin
docker exec -it airflow airflow users create \
  --username admin \
  --password admin \
  --firstname Admin \
  --lastname User \
  --role Admin \
  --email admin@example.com

## Jenkins - initial password
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword

## dags validation
docker exec -it airflow ls -l /opt/airflow/dags
docker exec -it airflow airflow dags list-import-errors

wget --no-check-certificate https://download.oracle.com/otn_software/linux/instantclient/instantclient-basiclite-linuxx64.zip
wget --no-check-certificate https://download.oracle.com/otn_software/linux/instantclient/2121000/instantclient-basiclite-linux.x64-21.21.0.0.0dbru.zip
wget --no-check-certificate https://download.oracle.com/otn_software/linux/instantclient/2121000/instantclient-basic-linux.x64-21.21.0.0.0dbru.zip
https://download.oracle.com/otn_software/linux/instantclient/1930000/instantclient-basic-linux.x64-19.30.0.0.0dbru.zip
wget --no-check-certificate https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/11.8.0/flyway-commandline-11.8.0-linux-x64.tar.gz

 ```
docker compose build --progress=plain --no-cache > build_oracle.log 2>&1
docker compose build --progress=plain 2>&1 | tee build_oracle.log

sudo docker compose up -d mysql
sudo docker compose up airflow-init
facesudo docker logs airflow-init --follow
sudo docker compose up -d airflow
sudo docker logs airflow --follow
sudo docker compose up -d airflow-scheduler
sudo docker compose up webhook
sudo docker compose up oracle-test
sudo docker compose ps
sudo docker compose down -v
sudo docker compose build

docker compose up -d mysql
docker compose up airflow-init
docker compose up -d airflow
docker compose up airflow-scheduler



```

$ docker run --rm --name oracle-db -p 1521:1521 -e ORACLE_PASSWORD=yourStrongPassword gvenzl/oracle-xe

# Airflow call API -> trigger DAG
$ curl -X POST "http://localhost:8080/api/v1/dags/mysql_dev_deploy/dagRuns" -u admin:admin -H "Content-Type: application/json" -d '{"conf": {"source": "manual-test"}}'

# git webhook
$ curl -X POST http://localhost:5000/webhook   -H "Content-Type: application/json"   -d '{"msg":"it just works"}'
{"airflow_status":200}

# criar connection no airflow
id: ebs_dev_conn
tipo: oracle
host: 172.30.71.145 (docker)
schema/login: celeghin
pwd: celeghin
extra:
{
  "thick_mode": true,
  "thick_mode_lib_dir": "/opt/oracle/instantclient_23_26",
  "service_name": "XE"
}

# issues
## TLS
docker tls issue with ca certs
CTRL+R certlm.msc
export base 64 cer (dnv root + zscaler)
sudo bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'
sudo cp /mnt/c/Users/cellui/Documents/Zscaler.cer /usr/local/share/ca-certificates/Zscaler.crt
sudo cp /mnt/c/Users/cellui/Documents/DNVRootCA.cer /usr/local/share/ca-certificates/DNVRootCA.crt
curl -I https://www.google.com

## RBAC
$ curl -X POST "http://localhost:8080/api/v1/dags/mysql_dev_deploy/dagRuns" -u admin:admin -H "Content-Type: application/json" -d '{"conf": {"source": "manual-test"}}'
{
  "detail": null,
  "status": 403,
  "title": "Forbidden",
  "type": "https://airflow.apache.org/docs/apache-airflow/2.9.1/stable-rest-api-ref.html#section/Errors/PermissionDenied"
}

usuario admin de ui , nao de api
add variavel no compose airflow
environment:
  AIRFLOW__API__AUTH_BACKENDS: airflow.api.auth.backend.basic_auth



# Context
flowchart LR
    Dev[Developer] --> GitHub
    GitHub --> Airflow
    Airflow --> BMC[BMC Ticket Validation]
    Airflow --> EBS[Oracle EBS Environment]
    Airflow --> Audit[(Versioned Logs / Audit)]


# Components
flowchart LR
    Scheduler[Airflow DAG Trigger] --> Validator
    Validator[BMC Ticket Validator] --> Planner
    Planner[Deployment Planner] --> Executor
    Executor[EBS Deployment Executor] --> Logger
    Logger[Audit Logger] --> Versioning[(Git Versioning)]


# Containers
flowchart TB
    subgraph CI_CD
        GitHub[GitHub Repository]
        Airflow[Apache Airflow Scheduler]
    end
    subgraph Deploy_Engine
        PythonDeploy[Python Deployment Engine]
        AuditLogs[(Audit & Version History)]
    end
    subgraph Governance
        BMC[BMC Ticket System]
    end
    subgraph Targets
        EBS_DEV[Oracle EBS - DEV]
        EBS_UAT[Oracle EBS - UAT]
        EBS_PROD[Oracle EBS - PROD]
    end
    GitHub --> Airflow
    Airflow --> PythonDeploy
    PythonDeploy --> BMC
    PythonDeploy --> EBS_DEV
    PythonDeploy --> EBS_UAT
    PythonDeploy --> EBS_PROD
    PythonDeploy --> AuditLogs
