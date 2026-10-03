drop table xx_aaa_123;

create table xx_aaa_123 (
   id          number not null,
   description varchar2(100),
   value       number(15,2),
   created_on  date,
   constraint xx_aaa_123_pk primary key ( id )
);

create index xx_aaa_123_desc_idx on
   xx_aaa_123 (
      description
   );

create or replace trigger xx_aaa_123_bi before
   insert on xx_aaa_123
   for each row
begin
   if :new.created_on is null then
      :new.created_on := sysdate;
   end if;
end;
/

create or replace package xx_aaa_123_pkg as
   procedure insert_line (
      p_id   number,
      p_desc varchar2,
      p_val  number
   );

end xx_aaa_123_pkg;
/

create or replace package body xx_aaa_123_pkg as

   procedure insert_line (
      p_id   number,
      p_desc varchar2,
      p_val  number
   ) is
   begin
      insert into xx_aaa_123 (
         id,
         description,
         value
      ) values
         ( p_id,
           p_desc,
           p_val );

   end insert_line;

end xx_aaa_123_pkg;
/