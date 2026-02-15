import oracledb

try:
    with oracledb.connect(
            user="system",
            password="oracle",
            dsn="localhost:1521/XE",
    ) as connection:
        print("Successfully connected!")
        with connection.cursor() as cursor:
            print('Dropping DEMO tables...')
            sql = 'drop table "AAAAA_DEMO2"'
            try:
                cursor.execute(sql)
            except Exception as e:
                print(e)

            sql = 'drop table "AAAAA_DEMO1"'
            try:
                cursor.execute(sql)
            except Exception as e:
                print(e)

            print('\nDropping table Flyway history...')
            sql = 'drop table "flyway_schema_history"'
            try:
                cursor.execute(sql)
            except Exception as e:
                print(e)

            print("\n All cleaned up")
except oracledb.Error as e:
    print(f"Connection failed: {e}")
