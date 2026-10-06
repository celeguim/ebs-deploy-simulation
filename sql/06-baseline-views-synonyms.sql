-- 06_baseline_views_synonyms.sql
   SET SERVEROUTPUT ON SIZE UNLIMITED
SET LINESIZE 400
SET TRIMSPOOL ON

declare
   l_ddl  clob;
   l_hash raw(32);
begin
   dbms_output.put_line('edition|'
                        || sys_context(
      'USERENV',
      'CURRENT_EDITION_NAME'
   )
                        || '|captured_at|' || to_char(
      systimestamp,
      'YYYY-MM-DD"T"HH24:MI:SS TZR'
   ));
   dbms_output.put_line('owner|object_type|object_name|status|last_ddl_time|sha256');
   for o in (
      select owner,
             object_name,
             object_type,
             status,
             last_ddl_time
        from dba_objects
       where object_name like 'XX%'
         and object_type in ( 'VIEW',
                              'SYNONYM' )
         and owner in ( 'APPS',
                        'XXABNK',
                        'XXDNVGL',
                        'XXFINBI',
                        'XXISV',
                        'XXBLACKLINE',
                        'XXCONV',
                        'XXODI' )
       order by owner,
                object_type,
                object_name
   ) loop
      begin
         l_ddl := dbms_metadata.get_ddl(
            o.object_type,
            o.object_name,
            o.owner
         );
         l_ddl := replace(
            l_ddl,
            chr(13),
            ''
         );
         l_hash := dbms_crypto.hash(
            l_ddl,
            dbms_crypto.hash_sh256
         );
         dbms_output.put_line(o.owner
                              || '|'
                              || o.object_type
                              || '|'
                              || o.object_name
                              || '|'
                              || o.status
                              || '|'
                              || to_char(
            o.last_ddl_time,
            'YYYY-MM-DD HH24:MI:SS'
         )
                              || '|' || rawtohex(l_hash));
      exception
         when others then
            dbms_output.put_line(o.owner
                                 || '|'
                                 || o.object_type
                                 || '|'
                                 || o.object_name
                                 || '|ERROR|' || substr(
               sqlerrm,
               1,
               200
            ));
      end;
   end loop;
end;
/