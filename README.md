# ebs-deploy-simulation

Inicialize o banco do Airflow (uma única vez)
docker exec -it airflow airflow db migrate

Crie o usuário admin (comando CORRETO)
docker exec -it airflow airflow users create \
  --username admin \
  --password admin \
  --firstname Admin \
  --lastname User \
  --role Admin \
  --email admin@example.com

