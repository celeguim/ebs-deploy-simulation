-- ============================================================
-- 07_dependencies.sql — Relatório de dependências
-- ============================================================
-- Dependências entre objetos customizados e objetos fora do escopo.
select owner,
       name,
       type,
       referenced_owner,
       referenced_name,
       referenced_type,
       case
          when referenced_owner in ( 'APPS',
                                     'XXABNK',
                                     'XXDNVGL',
                                     'XXFINBI',
                                     'XXISV',
                                     'XXBLACKLINE',
                                     'XXCONV',
                                     'XXODI',
                                     'XXPOWERCENTER',
                                     'SYSTEM_INTEGRATION' ) then
             'IN_SCOPE'
          else
             'EXTERNAL'
       end as dependency_scope
  from dba_dependencies
 where ( owner,
         name ) in (
   select owner,
          object_name
     from dba_objects
    where object_name like 'XX%'
      and object_type in ( 'PACKAGE',
                           'PACKAGE BODY',
                           'PROCEDURE',
                           'FUNCTION',
                           'VIEW',
                           'TRIGGER',
                           'TYPE',
                           'TYPE BODY',
                           'MATERIALIZED VIEW' )
      and owner in ( 'APPS',
                     'XXABNK',
                     'XXDNVGL',
                     'XXFINBI',
                     'XXISV',
                     'XXBLACKLINE',
                     'XXCONV',
                     'XXODI' )
)
   and referenced_owner not in ( 'SYS',
                                 'SYSTEM',
                                 'PUBLIC' )
 order by owner,
          name,
          referenced_owner,
          referenced_name;