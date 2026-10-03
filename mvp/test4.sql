VARIABLE rc REFCURSOR;

begin
   xx_cm_change_manager_pkg.get_dependents(
      p_owner       => 'APPS',
      p_object_name => 'XX_AAA_123',
      p_result      => :rc
   );
end;
/

PRINT rc;