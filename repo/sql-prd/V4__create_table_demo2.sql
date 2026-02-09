create table aaaaa_demo2 (
    col_id NUMBER(10),
    col_address VARCHAR2(50),
    constraint demo1_fk foreign key (col_id) references aaaaa_demo1(col_id)
);
