-- Em DEV, os desenvolvedores costumam alterar código diretamente na run edition, 
-- fora do ADOP, como parece ter ocorrido em 05 e 06/10?
-- Confirmar que a mudança foi na run edition, depois do cleanup
select edition_name,
       owner,
       object_type,
       object_name,
       status,
       created,
       last_ddl_time
  from dba_objects_ae
 where object_name like 'XX%'
   and last_ddl_time > to_date('2026-10-01 15:50:18','YYYY-MM-DD HH24:MI:SS')
 order by last_ddl_time desc;

-- Verificar o que a auditoria cobre
select *
  from audit_unified_enabled_policies;

-- Se nenhuma política auditar esses comandos, a trilha não terá o registro, 
-- e a atribuição por esse caminho não é possível.
select policy_name,
       audit_option,
       audit_option_type
  from audit_unified_policies
 where policy_name in (
   select policy_name
     from audit_unified_enabled_policies
)
   and ( audit_option like '%PACKAGE%'
    or audit_option like '%PROCEDURE%'
    or audit_option like '%FUNCTION%'
    or audit_option like '%TRIGGER%'
    or audit_option like '%TYPE%' )
 order by policy_name,
          audit_option;

select event_timestamp,
       dbusername,
       os_username,
       userhost,
       client_program_name,
       action_name,
       object_schema,
       object_name,
       return_code
  from unified_audit_trail
 where event_timestamp >= timestamp '2026-10-05 00:00:00'
   and object_name in ( 'XXDNVGL_QP_TEST_PKG',
                        'XXDNV_CHECK_EVENTS1',
                        'XXDNV_CHECK_EVENTS2' )
 order by event_timestamp;

select owner,
       trigger_name,
       trigger_type,
       triggering_event,
       base_object_type,
       status
  from dba_triggers
 where owner = 'XXISV'
   and trigger_name = 'XXISV_MSFTR_CTL_DDLH';

select line,
       text
  from dba_source
 where owner = 'XXISV'
   and name = 'XXISV_MSFTR_CTL_DDLH'
 order by line;

select *
  from unified_audit_trail;

-- confirmar ddl depois do cleanup
select policy_name,
       enabled_option,
       entity_name
  from audit_unified_enabled_policies
 order by policy_name;

-- consultar trilha para os objetos da captura
select event_timestamp,
       dbusername,
       os_username,
       userhost,
       client_program_name,
       action_name,
       object_schema,
       object_name,
       return_code
  from unified_audit_trail
 where event_timestamp >= timestamp '2026-10-05 00:00:00'
   and object_name in ( 'XXDNVGL_QP_TEST_PKG',
                        'XXDNV_CHECK_EVENTS1',
                        'XXDNV_CHECK_EVENTS2' )
 order by event_timestamp;

-- consultar erros de objetos invalidos
select owner,
       name,
       type,
       sequence,
       line,
       position,
       text
  from dba_errors
 where owner = 'APPS'
   and name in ( 'XXDNVGL_GCC_SC_INT_PKG',
                 'XXDNV_ESS_RESP_PKG' )
 order by name,
          type,
          sequence;

select event_timestamp,
       action_name,
       object_schema,
       object_name,
       dbusername,
       os_username,
       userhost,
       client_program_name,
       return_code,
       sql_text
  from unified_audit_trail
 where action_name not in ( 'LOGON',
                            'LOGOUT',
                            'LOGOFF',
                            'CREATE SESSION',
                            'ALTER SESSION',
                            'SET ROLE' )
  -- WHERE  event_timestamp >= TIMESTAMP '2026-10-05 00:00:00'
  -- where     object_schema = 'APPS'
  --    and object_name in ( 'XXDNVGL_GCC_SC_INT_PKG',
  --                         'XXDNV_ESS_RESP_PKG' )
   and object_name like 'XXDNV%'
 order by event_timestamp;

-- classificar os objetos por owner e por condição editioned/noneditioned
select owner,
       editionable,
       object_type,
       status,
       count(*) as object_count
  from dba_objects
 where owner in ( 'APPS',
                  'XXABNK',
                  'XXBLACKLINE',
                  'XXCONV',
                  'XXDNVGL',
                  'XXFINBI',
                  'XXISV' )
 group by owner,
          editionable,
          object_type,
          status
 order by owner,
          editionable,
          object_type,
          status;


-- identificar os objetos invalidos 
select owner,
       object_name,
       object_type,
       status,
       edition_name,
       editionable
  from dba_objects
 where owner in ( 'APPS',
                  'XXABNK',
                  'XXBLACKLINE',
                  'XXCONV',
                  'XXDNVGL',
                  'XXFINBI',
                  'XXISV' )
   and status = 'INVALID'
 order by owner,
          edition_name,
          object_type,
          object_name;



-- erros de plsql
select owner,
       name,
       type,
       sequence,
       line,
       position,
       text
  from dba_errors
 where owner = 'APPS'
   and name in ( 'DENORM_DEMO_PKG',
                 'QP_BUILD_SOURCING_PVT_TMP' )
 order by name,
          type,
          sequence;

-- estado das materialized views
select owner,
       mview_name,
       compile_state,
       staleness,
       last_refresh_type,
       last_refresh_date
  from dba_mviews
 where owner = 'APPS'
   and mview_name in ( 'OZF_EARNING_SUMMARY_MV',
                       'XXDNVGL_IORA_EXP_ITEMS_MV',
                       'XXDNVGL_SLA_PA_VW' )
 order by mview_name;

select owner,
       object_name,
       object_type,
       status
  from dba_objects
 where object_name = 'DEPARTMENT_DENORMS'
 order by owner,
          object_type;

select owner,
       synonym_name,
       table_owner,
       table_name,
       db_link
  from dba_synonyms
 where synonym_name = 'DEPARTMENT_DENORMS'
 order by owner;

select line,
       text
  from dba_source
 where owner = 'APPS'
   and name = 'DENORM_DEMO_PKG'
   and type = 'PACKAGE'
   and line between 1 and 15
 order by line;

select owner,
       object_name,
       object_type,
       status
  from dba_objects
 where object_name in ( 'DEPARTMENT_DENORMS',
                        'EMPLOYEES' )
 order by object_name,
          owner,
          object_type;

select owner,
       synonym_name,
       table_owner,
       table_name,
       db_link
  from dba_synonyms
 where synonym_name in ( 'DEPARTMENT_DENORMS',
                         'EMPLOYEES' )
 order by synonym_name,
          owner;


select owner,
       object_name,
       object_type,
       status
  from dba_objects
 where owner = 'XXISV'
   and object_name = 'XXISV_MSFTR_CTL_DDLH'
 order by object_type;

select owner,
       trigger_name,
       status,
       triggering_event,
       table_owner,
       table_name,
       trigger_type,
       action_type
  from dba_triggers
 where owner = 'XXISV'
   and trigger_name = 'XXISV_MSFTR_CTL_DDLH';

select line,
       text
  from dba_source
 where owner = 'XXISV'
   and name = 'XXISV_MSFTR_CTL_DDLH'
   and type = 'TRIGGER'
 order by line;

select owner,
       object_name,
       object_type,
       status
  from dba_objects
 where owner = 'XXISV'
   and object_name = 'XXISV_MSFTS_CTL_DDLH';

select column_id,
       column_name,
       data_type,
       data_length
  from dba_tab_columns
 where owner = 'XXISV'
   and table_name = 'XXISV_MSFTS_CTL_DDLH'
 order by column_id;


select stamp,
       username,
       osuser,
       machine,
       operation,
       objtype,
       objname,
       dsc_patch,
       dsc_upg,
       seq
  from xxisv.xxisv_msfts_ctl_ddlh
 where stamp >= date '2026-10-01'
   and stamp < date '2026-10-09'
 order by stamp,
          seq;



select owner,
       name,
       type,
       referenced_owner,
       referenced_name,
       referenced_type,
       dependency_type
  from dba_dependencies
 where owner = 'APPS'
   and name in ( 'DENORM_DEMO_PKG',
                 'XXDNVGL_GCC_SC_INT_PKG',
                 'XXDNV_ESS_RESP_PKG' )
 order by name,
          type,
          referenced_owner,
          referenced_name;


select owner,
       name,
       type,
       sequence,
       line,
       position,
       attribute,
       text
  from dba_errors
 where owner = 'APPS'
   and name in ( 'DENORM_DEMO_PKG',
                 'XXDNVGL_GCC_SC_INT_PKG',
                 'XXDNV_ESS_RESP_PKG' )
 order by name,
          type,
          sequence;



select owner,
       object_name,
       object_type,
       status,
       edition_name
  from dba_objects
 where owner = 'APPS'
   and object_name = 'XXDNV_ESS_RESP_PKG'
 order by object_type;

select owner,
       name,
       type,
       referenced_owner,
       referenced_name,
       referenced_type,
       dependency_type
  from dba_dependencies
--  where owner = 'APPS'
--    and name = 'XXDNV_ESS_RESP_PKG'
 where name = 'XXDNV_ESS_RESP_PKG'
 order by type,
          referenced_owner,
          referenced_name;

select owner,
       object_name,
       object_type,
       edition_name,
       status
  from dba_objects
 where owner = 'APPS'
   and object_name = 'XXDNV_ESS_RESP_PKG'
 order by edition_name,
          object_type;


select owner,
       object_name,
       object_type,
       edition_name,
       status
  from dba_objects_ae
 where owner = 'APPS'
   and object_name = 'XXDNV_ESS_RESP_PKG'
 order by edition_name,
          object_type;


select owner,
       name,
       type,
       referenced_owner,
       referenced_name,
       referenced_type,
       dependency_type
  from dba_dependencies
 where owner in ( 'XXABNK',
                  'XXBLACKLINE',
                  'XXCONV',
                  'XXDNVGL',
                  'XXFINBI',
                  'XXISV' )
 order by owner,
          name,
          type,
          referenced_owner,
          referenced_name;