-- 05_baseline_plsql.sql
-- Execute como script (F5). Requer EXECUTE em DBMS_CRYPTO.
-- A lista de owners abaixo deve refletir a allowlist aprovada.

   SET SERVEROUTPUT ON SIZE 1000000
SET LINESIZE 400
SET TRIMSPOOL ON

declare
   l_clob  clob;
   l_line  varchar2(32767);
   l_count pls_integer;
   l_hash  raw(32);
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

   dbms_output.put_line('owner|object_type|object_name|status|last_ddl_time|line_count|sha256');
   for o in (
      select owner,
             object_name,
             object_type,
             status,
             last_ddl_time
        from dba_objects
       where object_name like 'XX%'
         and object_type in ( 'PACKAGE',
                              'PACKAGE BODY',
                              'PROCEDURE',
                              'FUNCTION',
                              'TYPE',
                              'TYPE BODY',
                              'TRIGGER' )
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
      dbms_lob.createtemporary(
         l_clob,
         true
      );
      l_count := 0;
      for s in (
         select text
           from dba_source
          where owner = o.owner
            and name = o.object_name
            and type = o.object_type
          order by line
      ) loop
      -- remove CR e espaços/tabs antes do fim da linha
         l_line := regexp_replace(
            replace(
               s.text,
               chr(13),
               ''
            ),
            '[[:blank:]]+('
            || chr(10)
            || ')?$',
            '\1'
         );

         if length(l_line) > 0 then
            dbms_lob.writeappend(
               l_clob,
               length(l_line),
               l_line
            );
         end if;

         l_count := l_count + 1;
      end loop;

      if l_count = 0 then
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
         ) || '|0|NO_SOURCE');
      else
         l_hash := dbms_crypto.hash(
            l_clob,
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
                              || '|'
                              || l_count
                              || '|'
                              || rawtohex(l_hash) || '\n');

      end if;

      dbms_lob.freetemporary(l_clob);
   end loop;

end;
/