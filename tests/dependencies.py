import os
import oracledb
from collections import defaultdict, deque

# Configuration
CONN_PARAMS = {
    "user": "system",
    "password": "oracle",
    "dsn": "localhost:1521/XE"
}
SCHEMA = "system"


def create_schema():
    print(CONN_PARAMS)

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
            cursor.execute("create user celeghin identified by celeghin")
            cursor.execute("grant connect, resource to celeghin")
            cursor.execute("ALTER USER celeghin QUOTA 100M ON USERS")
            print("User celeghin created successfully")

            sql = "SELECT banner FROM v$version"
            cursor.execute(sql)
            for row in cursor:
                print(row)



def get_ordered_ddl(schema):
    conn = oracledb.connect(**CONN_PARAMS)
    cursor = conn.cursor()

    # 1. Fetch all objects and their types
    cursor.execute(
        "SELECT object_name, object_type FROM dba_objects WHERE owner = :s AND object_type IN ('TABLE','VIEW','PROCEDURE')",
        s=schema,
    )
    obj_metadata = {name: otype for name, otype in cursor}

    # 2. Build Dependency Graph (Parent -> Child)
    # We want: Table (Parent) -> View (Child)
    adj = defaultdict(list)
    in_degree = {name: 0 for name in obj_metadata}

    sql_deps = """
    SELECT referenced_name, name 
    FROM dba_dependencies 
    WHERE owner = :s AND referenced_owner = :s
    AND name != referenced_name
    """
    for parent, child in cursor.execute(sql_deps, s=schema):
        if parent in obj_metadata and child in obj_metadata:
            adj[parent].append(child)
            in_degree[child] += 1

    # 3. Topological Sort (Kahn's Algorithm)
    queue = deque([obj for obj in obj_metadata if in_degree[obj] == 0])
    ordered_objects = []
    while queue:
        u = queue.popleft()
        ordered_objects.append(u)
        for v in adj[u]:
            in_degree[v] -= 1
            if in_degree[v] == 0:
                queue.append(v)

    print(queue)
    print(ordered_objects)

    # 4. Extract DDL in Order
    # print(f"\n--- DDL REPORT FOR {schema} ---")
    # for obj_name in ordered_objects:
    #     obj_type = obj_metadata[obj_name]
    #     try:
    #         # DBMS_METADATA.GET_DDL returns a CLOB
    #         ddl = cursor.callfunc(
    #             "DBMS_METADATA.GET_DDL",
    #             oracledb.DB_TYPE_CLOB,
    #             [obj_type, obj_name, schema],
    #         )
    #         print(f"\n-- Object: {obj_name} ({obj_type})")
    #         print(ddl.read() if hasattr(ddl, "read") else ddl)
    #     except oracledb.Error as e:
    #         print(f"Error extracting {obj_name}: {e}")

    conn.close()


if __name__ == "__main__":
    get_ordered_ddl(SCHEMA.upper())
    # create_schema()
