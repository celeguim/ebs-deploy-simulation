from flask import Flask, request
import requests

app = Flask(__name__)

AIRFLOW_URL = "http://airflow:8080/api/v1/dags/mysql_dev_deploy/dagRuns"
AUTH = ("admin", "admin")

@app.route("/webhook", methods=["POST"])
def webhook():
    payload = request.json
    print("Received from Git:", payload)

    resp = requests.post(
        AIRFLOW_URL,
        auth=AUTH,
        json={"conf": {"git_payload": payload}}
    )

    return {"airflow_status": resp.status_code}, 200

app.run(host="0.0.0.0", port=5000)
