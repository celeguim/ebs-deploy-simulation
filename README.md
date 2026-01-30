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

wget --no-check-certificate https://download.oracle.com/otn_software/linux/instantclient/instantclient-basiclite-linuxx64.zip
wget --no-check-certificate https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/11.8.0/flyway-commandline-11.8.0-linux-x64.tar.gz

 ```
docker compose build --progress=plain --no-cache > build_oracle.log 2>&1
docker compose build --progress=plain 2>&1 | tee build_oracle.log

sudo docker compose up -d mysql
sudo docker compose up -d oracle
sudo docker compose up airflow-init
sudo docker logs airflow-init --follow
sudo docker compose up -d airflow
sudo docker logs airflow --follow
sudo docker compose up -d airflow-scheduler
sudo docker compose ps
sudo docker compose down -v
sudo docker compose build
```

$ docker run --rm --name oracle-db -p 1521:1521 -e ORACLE_PASSWORD=yourStrongPassword gvenzl/oracle-xe

# criar connection no airflow
tipo: oracle
extra:
{
  "thick_mode": true,
  "thick_mode_lib_dir": "/opt/oracle/instantclient_21_1",
  "service_name": "NOME_DO_SEU_SERVICO_EBS"
}

docker tls issue with ca certs
CTRL+R certlm.msc
export base 64 cer (dnv root + zscaler)
sudo bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'
sudo cp /mnt/c/Users/cellui/Documents/Zscaler.cer /usr/local/share/ca-certificates/Zscaler.crt
sudo cp /mnt/c/Users/cellui/Documents/DNVRootCA.cer /usr/local/share/ca-certificates/DNVRootCA.crt
curl -I https://www.google.com
