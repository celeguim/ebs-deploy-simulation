-- ============================================================
-- 04_inventory.sql — Inventário de objetos customizados
-- ============================================================
-- Lista objetos XX% nos schemas APPS e customizados,
-- classifica por owner, tipo, edition, e status.
-- Schemas customizados com objetos XX% (excluindo Oracle e EBS padrão)
select distinct owner
  from dba_objects_ae
 where object_name like 'XX%'
   and owner not in ( 'SYS',
                      'SYSTEM',
                      'PUBLIC',
                      'XDB',
                      'MDSYS',
                      'CTXSYS',
                      'ORDSYS',
                      'ORDDATA',
                      'ORDPLUGINS',
                      'SI_INFORMTN_SCHEMA',
                      'OLAPSYS',
                      'WMSYS',
                      'DBSNMP',
                      'OUTLN',
                      'APPQOSSYS',
                      'GSMADMIN_INTERNAL' )
   and owner not in (
   select schema_name
     from dba_registry
    where schema_name = owner
)
 order by owner;

-- Inventário completo: owner, tipo, edition, contagem
select owner,
       object_type,
       nvl(
          edition_name,
          '(noneditioned)'
       ) as edition_name,
       count(*) as qtd
  from dba_objects_ae
 where object_name like 'XX%'
   and owner not in ( 'SYS',
                      'SYSTEM',
                      'PUBLIC' )
   and owner not in ( 'DBSNMP',
                      'OUTLN',
                      'APPQOSSYS',
                      'GSMADMIN_INTERNAL' )
 group by owner,
          object_type,
          edition_name
 order by owner,
          object_type,
          edition_name;

-- Detalhe: objetos editioned vs noneditioned por schema
select owner,
       case
          when edition_name is null then
             'NONEDITIONED'
          else
             'EDITIONED'
       end as edition_status,
       count(*) as qtd
  from dba_objects_ae
 where object_name like 'XX%'
   and owner not in ( 'SYS',
                      'SYSTEM',
                      'PUBLIC' )
 group by owner,
          case
             when edition_name is null then
                'NONEDITIONED'
             else
                'EDITIONED'
          end
 order by owner,
          edition_status;

-- Objetos PL/SQL editioned (package, procedure, function, type, trigger)
-- que estão em múltiplas edições — útil para entender o histórico
select owner,
       object_name,
       object_type,
       edition_name,
       status
  from dba_objects_ae
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
   and edition_name is not null
 order by owner,
          object_name,
          edition_name;