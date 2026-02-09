flowchart LR
    Scheduler[Airflow DAG Trigger] --> Validator
    Validator[BMC Ticket Validator] --> Planner
    Planner[Deployment Planner] --> Executor
    Executor[EBS Deployment Executor] --> Logger
    Logger[Audit Logger] --> Versioning[(Git Versioning)]
