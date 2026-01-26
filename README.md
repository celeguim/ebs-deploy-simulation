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

docker compose up -d mysql
docker compose up -d airflow-init
docker logs airflow-init --follow
docker compose up -d airflow
docker compose up -d airflow-scheduler
docker compose ps
docker compose down -v
docker compose build
