CREATE TABLE xx_demo2 (
  id SERIAL PRIMARY KEY,
  name varchar(100),
  demo1_id bigint unsigned,
  constraint demo1_fk
	foreign key (demo1_id)
    references xx_demo1 (id)
);
