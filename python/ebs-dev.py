import oracledb
import getpass

user = "APPS"
password = getpass.getpass()
dsn = "ocifra2600-umjv1-scan.findbpriad2.financevcn.oraclevcn.com:1521/DEV"

try:
    # for thick client
    oracledb.init_oracle_client()
    with oracledb.connect(user=user, password=password, dsn=dsn) as connection:
        print("Successfully connected!")
        with connection.cursor() as cursor:
            # Simple query
            sql = "SELECT SYSDATE FROM DUAL"
            for row in cursor.execute(sql):
                print(row)

except oracledb.Error as e:
    print(f"Connection failed: {e}")
