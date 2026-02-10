import os
import oracledb

try:
    # for thick client
    oracledb.init_oracle_client()
    print("Oracle Thick mode initialized")
    print(f"os.getenv(DB_DSN) : {os.getenv('DB_DSN')}" )

    with oracledb.connect(
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASSWORD"),
            dsn=os.getenv("DB_DSN")
    ) as connection:
        print("Successfully connected!")
        with connection.cursor() as cursor:
            sql = "SELECT to_char(SYSDATE, 'yyyy-MM-dd HH:MI:SS') FROM DUAL"
            for row in cursor.execute(sql):
                print(row)
            # cursor.execute("create user celeghin identified by celeghin")
            # cursor.execute("grant connect, resource to celeghin")
            # cursor.execute("ALTER USER celeghin QUOTA 100M ON USERS")
            # print("User celeghin created successfully")

except oracledb.Error as e:
    print(f"Connection failed: {e}")
