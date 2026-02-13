import oracledb

try:
    with oracledb.connect(
            user="system",
            password="oracle",
            dsn="localhost:1521/XE",
    ) as connection:
        print("Successfully connected!")
        with connection.cursor() as cursor:
            print('Looking for DEMO tables...')
            sql = "select owner, table_name from all_tables where table_name like '%DEMO%'"
            cursor.execute(sql)
            for row in cursor:
                print(row)

            print('\nLooking for Flyway history...')
            sql = 'select * from  "SYSTEM"."flyway_schema_history"'
            cursor.execute(sql)
            for row in cursor:
                print(row)

except oracledb.Error as e:
    print(f"Connection failed: {e}")
