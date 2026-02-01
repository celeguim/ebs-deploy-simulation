flowchart LR
    Dev[Developer] --> GitHub
    GitHub --> Airflow
    Airflow --> BMC[BMC Ticket Validation]
    Airflow --> EBS[Oracle EBS Environment]
    Airflow --> Audit[(Versioned Logs / Audit)]
