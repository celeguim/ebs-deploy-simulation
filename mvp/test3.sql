VARIABLE rc REFCURSOR;

begin
   xx_change_manager_pkg.get_dependencies(
      p_owner       => 'APPS',
      p_object_name => 'XX_AAA_123_PKG',
      p_result      => :rc
   );
end;
/

PRINT rc;