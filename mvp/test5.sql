select xx_change_manager_pkg.get_ddl(
   'APPS',
   'XX_AAA_123',
   'TABLE'
)
  from dual;

select xx_cm_change_manager_pkg.get_ddl(
   'APPS',
   'XX_AAA_123_PKG',
   'PACKAGE'
)
  from dual;