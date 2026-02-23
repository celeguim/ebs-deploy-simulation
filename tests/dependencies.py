import csv
from datetime import datetime
import os
import oracledb
from collections import defaultdict, deque

# Configuration
USER = os.getenv("EBS_USER")
PWD = os.getenv("EBS_PWD")
DSN = os.getenv("EBS_DSN")
SCHEMA = "APPS"
CONN_PARAMS = {"user": USER, "password": PWD, "dsn": DSN}


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
    # for thick client
    oracledb.init_oracle_client()
    conn = oracledb.connect(**CONN_PARAMS)
    cursor = conn.cursor()

    # 1. Fetch all objects and their types
    #         "SELECT object_name, object_type FROM dba_objects WHERE owner = :s AND object_type IN ('TABLE','VIEW','PROCEDURE')",
    cursor.execute(
        "SELECT object_name, object_type FROM dba_objects WHERE owner = :s AND object_type IN ('TABLE')",
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
        print(f"Processing: {parent}/{child}")
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

    print(ordered_objects)
    # ['TEST_DATA', 'TEST_VIEW', 'TEST_PROC', 'TEST_VIEW1', 'TEST_VIEW2', 'TEST_PROC1', 'TEST_PROC2']

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


def generate_ebs_delta_report(start_date):
    # for thick client
    oracledb.init_oracle_client()
    conn = oracledb.connect(**CONN_PARAMS)
    cursor = conn.cursor()

    # 1. Performance-Optimized Metadata Fetch
    # We filter by LAST_DDL_TIME immediately to reduce the dataset
    print(f"Filtering objects modified since {start_date}...")

    #           AND object_type IN ('TABLE', 'VIEW', 'PROCEDURE', 'FUNCTION', 'PACKAGE', 'PACKAGE BODY', 'TYPE')
    cursor.execute(
        """
        SELECT object_name, object_type, created, last_ddl_time 
        FROM dba_objects 
        WHERE owner = :s 
          AND last_ddl_time >= :dt
          AND object_type IN ('TABLE')
          AND object_name NOT LIKE 'BIN$%'
    """,
        s=SCHEMA,
        dt=start_date,
    )

    obj_info = {
        row[0]: {"type": row[1], "created": row[2], "updated": row[3]} for row in cursor
    }
    target_objects = list(obj_info.keys())

    if not target_objects:
        print("No modified objects found for the given timeframe.")
        return

    # 2. Optimized Dependency Fetch
    # We only look for dependencies involving our filtered list of objects
    print(f"Building dependency graph for {len(target_objects)} objects...")

    # Create a temporary table to hold our target names (Session based)
    try:
        cursor.execute(
            "CREATE GLOBAL TEMPORARY TABLE temp_obj_list (obj_name VARCHAR2(128)) ON COMMIT PRESERVE ROWS"
        )
    except oracledb.DatabaseError as e:
        if "ORA-00955" not in str(e):
            raise  # Ignore if table already exists

    cursor.execute("DELETE FROM temp_obj_list")

    # Efficiently bulk-insert the list of target objects
    cursor.executemany(
        "INSERT INTO temp_obj_list (obj_name) VALUES (:1)",
        [(x,) for x in target_objects],
    )

    # Now run the dependency query joining against our temp table
    dep_sql = """
        SELECT referenced_name, name 
        FROM dba_dependencies 
        WHERE owner = :s 
          AND referenced_owner = :s
          AND name IN (SELECT obj_name FROM temp_obj_list)
          AND referenced_name IN (SELECT obj_name FROM temp_obj_list)
          AND name != referenced_name
    """

    adj = defaultdict(list)
    in_degree = {name: 0 for name in target_objects}

    cursor.execute(dep_sql, s=SCHEMA)
    for parent, child in cursor:
        adj[parent].append(child)
        in_degree[child] += 1

    # 3. Topological Sort (Kahn's)
    queue = deque([name for name in target_objects if in_degree[name] == 0])
    ordered_names = []
    while queue:
        u = queue.popleft()
        ordered_names.append(u)
        for v in adj[u]:
            in_degree[v] -= 1
            if in_degree[v] == 0:
                queue.append(v)

    # 4. Generate CSV
    filename = f"ebs_delta_report_{datetime.now().strftime('%Y%m%d_%H%M')}.csv"
    with open(filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(
            ["Order", "Object Name", "Type", "Created Date", "Last Modified", "DDL"]
        )

        # Set Metadata transformations to speed up DDL extraction
        cursor.execute(
            "BEGIN dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'SQLTERMINATOR', true); END;"
        )
        cursor.execute(
            "BEGIN dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'CONSTRAINTS', false); END;"
        )

        for idx, name in enumerate(ordered_names, 1):
            otype = obj_info[name]["type"]
            try:
                # Use standard DDL fetch
                ddl = cursor.callfunc(
                    "dbms_metadata.get_ddl",
                    oracledb.DB_TYPE_CLOB,
                    [otype, name, SCHEMA],
                )
                writer.writerow(
                    [
                        idx,
                        name,
                        otype,
                        obj_info[name]["created"],
                        obj_info[name]["updated"],
                        ddl.read().strip(),
                    ]
                )
            except Exception as e:
                writer.writerow(
                    [
                        idx,
                        name,
                        otype,
                        obj_info[name]["created"],
                        obj_info[name]["updated"],
                        f"Error: {str(e)}",
                    ]
                )

        # 5. Append Foreign Keys for modified tables ONLY
        writer.writerow(["---", "FOREIGN KEYS (Delta)", "---", "---", "---", "---"])
        modified_tables = [n for n in target_objects if obj_info[n]["type"] == "TABLE"]

        if modified_tables:
            cursor.execute(
                """
                SELECT constraint_name, table_name FROM dba_constraints 
                WHERE owner = :s AND constraint_type = 'R'
                AND table_name IN (SELECT column_value FROM TABLE(:tab))
            """,
                s=SCHEMA,
                tab=modified_tables,
            )

            for fk_name, table_name in cursor.fetchall():
                try:
                    fk_ddl = cursor.callfunc(
                        "dbms_metadata.get_ddl",
                        oracledb.DB_TYPE_CLOB,
                        ["REF_CONSTRAINT", fk_name, SCHEMA],
                    )
                    writer.writerow(
                        [
                            "FK",
                            fk_name,
                            f"FK on {table_name}",
                            "N/A",
                            "N/A",
                            fk_ddl.read().strip(),
                        ]
                    )
                except:
                    pass

    print(f"Done! Report saved to {filename}")
    conn.close()


def generate_simple_order_report(start_date):

    print("Getting connection")
    oracledb.init_oracle_client()
    conn = oracledb.connect(**CONN_PARAMS)
    cursor = conn.cursor()

    # 1. Fetch Delta Objects (Filtered by Date)
    print(f"Fetching objects modified since {start_date}...")
    # AND object_type IN ('TABLE', 'VIEW', 'PROCEDURE', 'FUNCTION', 'PACKAGE', 'PACKAGE BODY', 'TYPE')
    cursor.execute(
        """
        SELECT object_name, object_type, created, last_ddl_time 
        FROM dba_objects 
        WHERE owner = :s 
          AND last_ddl_time >= :dt
          AND object_type IN ('TABLE', 'VIEW', 'PROCEDURE', 'FUNCTION', 'PACKAGE', 'PACKAGE BODY', 'TYPE')
          AND object_name NOT LIKE 'BIN$%'
    """,
        s=SCHEMA,
        dt=start_date,
    )

    # Store metadata and a simple list of names for the graph
    obj_info = {
        row[0]: {"type": row[1], "created": row[2], "updated": row[3]}
        for row in cursor.fetchall()
    }
    target_names = list(obj_info.keys())

    if not target_names:
        print("No modified objects found.")
        return

    # 2. Build Dependency Graph
    # We query DBA_DEPENDENCIES for relationships between our filtered objects
    print(f"Analyzing dependencies for {len(target_names)} objects...")
    adj = defaultdict(list)
    in_degree = {name: 0 for name in target_names}

    # Using a subquery to avoid ORA-01484 by processing the list in memory
    # For very large lists (>1000), we filter DBA_DEPENDENCIES using the OWNER first
    cursor.execute(
        """
        SELECT referenced_name, name 
        FROM dba_dependencies 
        WHERE owner = :s 
          AND referenced_owner = :s
          AND name != referenced_name
    """,
        s=SCHEMA,
    )

    for ref_name, name in cursor:
        # print(f"Checking ref_name/name: {ref_name}/{name}")
        if ref_name in obj_info and name in obj_info:
            print(f"Dependency found ref_name/name: {ref_name}/{name}")
            adj[ref_name].append(name)
            in_degree[name] += 1

    # 3. Topological Sort (The Creation Order)
    queue = deque([name for name in target_names if in_degree[name] == 0])
    ordered_list = []
    while queue:
        u = queue.popleft()
        ordered_list.append(u)
        for v in adj[u]:
            in_degree[v] -= 1
            if in_degree[v] == 0:
                queue.append(v)

    # 4. Generate CSV
    filename = f"ebs_order_only_{datetime.now().strftime('%Y%m%d')}.csv"
    with open(filename, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["Sequence", "Object Name", "Type", "Created", "Last Modified"])

        for i, name in enumerate(ordered_list, 1):
            meta = obj_info[name]
            writer.writerow([i, name, meta["type"], meta["created"], meta["updated"]])

    print(f"Success! Ordered list saved to {filename}")
    conn.close()


if __name__ == "__main__":
    # get_ordered_ddl(SCHEMA.upper())
    # create_schema()

    init_time = datetime.now()
    start_date = datetime.strptime("2026-01-01 00:00:00", "%Y-%m-%d %H:%M:%S")
    # generate_ebs_delta_report(start_date)
    generate_simple_order_report(start_date)
    end_time = datetime.now()
    print("Init time: ", init_time)
    print("End time: ", end_time)
