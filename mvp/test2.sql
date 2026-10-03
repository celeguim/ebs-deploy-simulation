VARIABLE rc REFCURSOR;

begin
   xx_change_manager_pkg.get_related_objects(
      p_owner       => 'APPS',
      p_object_name => 'XX_AAA_123',
      p_object_type => 'TABLE',
      p_result      => :rc
   );
end;
/

PRINT rc;