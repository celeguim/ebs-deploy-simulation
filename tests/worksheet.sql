CREATE TABLE aaaaa_demo1 (
    col_id NUMBER(10) NOT NULL,
    col_name VARCHAR2(50) NOT NULL,
    col_city VARCHAR2(50),
    CONSTRAINT demo1_pk PRIMARY KEY (col_id)
);

create table aaaaa_demo2 (
    col_id NUMBER(10),
    col_address VARCHAR2(50),
    constraint demo1_fk foreign key (col_id) references aaaaa_demo1(col_id)
);

select table_name from user_tables where table_name like '%DEMO%';
select * from aaaaa_demo1;
select * from aaaaa_demo2;

select * from "flyway_schema_history" order by 1;

--delete from "flyway_schema_history";
--commit;

