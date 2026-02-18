-- DEPENDENCIES

-- create sample objects --
CREATE TABLE celeghin.test_data (id NUMBER, name VARCHAR2(50));

CREATE OR REPLACE VIEW celeghin.test_view AS SELECT name FROM celeghin.test_data;
CREATE OR REPLACE VIEW celeghin.test_view1 AS SELECT name FROM celeghin.test_view;
CREATE OR REPLACE VIEW celeghin.test_view2 AS SELECT name FROM celeghin.test_view1;

CREATE OR REPLACE PROCEDURE celeghin.test_proc AS l_name VARCHAR2(50);
BEGIN SELECT name INTO l_name FROM celeghin.test_view WHERE ROWNUM = 1; END;

CREATE OR REPLACE PROCEDURE celeghin.test_proc1 AS l_name VARCHAR2(50);
BEGIN SELECT name INTO l_name FROM celeghin.test_view1 WHERE ROWNUM = 1; END;

CREATE OR REPLACE PROCEDURE celeghin.test_proc2 AS l_name VARCHAR2(50);
BEGIN SELECT name INTO l_name FROM celeghin.test_view2 WHERE ROWNUM = 1; END;

select * from all_users;

SELECT owner, 
       name, 
       type, 
       referenced_owner, 
       referenced_name, 
       referenced_type
FROM dba_dependencies
WHERE owner = 'ORACLE_OCM'
START WITH referenced_name IS NOT NULL
CONNECT BY PRIOR name = referenced_name 
       AND PRIOR type = referenced_type;
-- ORDER SIBLINGS BY level;

select * from dba_dependencies where owner = 'SYSTEM' and referenced_name is not null;

select * from DEPTREE;

