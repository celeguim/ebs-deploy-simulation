SELECT grantee,
       granted_role,
       default_role,
       admin_option,
       delegate_option
  FROM dba_role_privs
 WHERE granted_role IN (
       'DNVGL_DEVELOPER_ROLE',
       'DEVELOPER_ROLE'
 )
 ORDER BY granted_role, grantee;