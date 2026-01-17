# ebs-deploy-simulation

## db initialization
docker exec -it airflow airflow db migrate

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

docker compose up -d postgres
docker compose up -d airflow-init
docker compose up -d airflow
docker compose up -d airflow-scheduler
docker compose ps
docker compose down -v
docker compose build
