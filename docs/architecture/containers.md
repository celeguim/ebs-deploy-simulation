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
