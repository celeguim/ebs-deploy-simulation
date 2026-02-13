import os
import oracledb

try:
    with oracledb.connect(
            user="system",
            password="oracle",
            dsn="localhost:1521/XE",
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

            sql = "SELECT banner FROM v$version"
            cursor.execute(sql)
            for row in cursor:
                print(row)

except oracledb.Error as e:
    print(f"Connection failed: {e}")
