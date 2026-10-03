select object_name,
       object_type,
       status
  from user_objects
 where object_name like '%CHANGE_MANAGER_PKG';

 VARIABLE rc REFCURSOR;

BEGIN
    xx_cm_change_manager_pkg.find_objects(
        p_owner       => 'APPS',
        p_object_name => 'XX_CM_ORDER_POC',
        p_result      => :rc
    );
END;
/

PRINT rc;


