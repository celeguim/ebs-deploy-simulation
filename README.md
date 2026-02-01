# ebs-deploy-simulation

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

 ```
sudo docker compose up -d mysql
sudo docker compose up -d airflow-init
sudo docker logs airflow-init --follow
sudo docker compose up -d airflow
sudo docker logs airflow --follow
sudo docker compose up -d airflow-scheduler
sudo docker compose ps
sudo docker compose down -v
sudo docker compose build
```

docker tls issue with ca certs
CTRL+R certlm.msc
export base 64 cer (dnv root + zscaler)
sudo bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'
sudo cp /mnt/c/Users/cellui/Documents/Zscaler.cer /usr/local/share/ca-certificates/Zscaler.crt
sudo cp /mnt/c/Users/cellui/Documents/DNVRootCA.cer /usr/local/share/ca-certificates/DNVRootCA.crt
curl -I https://www.google.com

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
