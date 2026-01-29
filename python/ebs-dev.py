import oracledb
import getpass

# user = "APPS"
# password = getpass.getpass()
# dsn = "ocifra2600-umjv1-scan.findbpriad2.financevcn.oraclevcn.com:1521/DEV"

user = "system"
password = "yourStrongPassword"
dsn = "localhost:1521/XE"

try:
    # for thick client
    # oracledb.init_oracle_client()
    with oracledb.connect(user=user, password=password, dsn=dsn) as connection:
        print("Successfully connected!")
        with connection.cursor() as cursor:
            # Simple query
            sql = "SELECT to_char(SYSDATE, 'yyyy-MM-dd HH:MI:SS') FROM DUAL"
            for row in cursor.execute(sql):
                print(row)
            # cursor.execute("create user celeghin identified by celeghin")
            cursor.execute("grant connect, resource to celeghin")
except oracledb.Error as e:
    print(f"Connection failed: {e}")
