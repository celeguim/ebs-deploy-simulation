# Enable Thick Mode
# On Linux, do NOT pass lib_dir; it uses the system path (ldconfig) set in Docker
import os
import oracledb

try:
    oracledb.init_oracle_client()
    print("Oracle Thick mode initialized.")
except Exception as e:
    print(f"Failed to initialize Thick mode: {e}")

# Proceed with connection
print("trying to connect to ebs")
conn = oracledb.connect(
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    dsn=os.getenv("DB_DSN")
)
print("connected to Oracle")
print(conn)
