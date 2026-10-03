create or replace package xx_cm_change_manager_pkg as

    /*
     * Localiza objetos Oracle disponíveis para o usuário.
     *
     * p_object_name aceita:
     *   XX_TESTE
     *   XX_%
     *   NULL = todos os objetos do owner
     */
   procedure find_objects (
      p_owner       in varchar2,
      p_object_name in varchar2 default null,
      p_result      out sys_refcursor
   );


    /*
     * Retorna objetos estruturalmente relacionados ao objeto.
     *
     * Exemplo para TABLE:
     *   INDEX
     *   CONSTRAINT
     *   TRIGGER
     */
   procedure get_related_objects (
      p_owner       in varchar2,
      p_object_name in varchar2,
      p_object_type in varchar2,
      p_result      out sys_refcursor
   );


    /*
     * Retorna objetos dos quais o objeto atual depende.
     *
     * Exemplo:
     *
     *   XX_PEDIDO_PKG
     *          |
     *          +-- XX_PEDIDO
     *          +-- XX_CLIENTE
     */
   procedure get_dependencies (
      p_owner       in varchar2,
      p_object_name in varchar2,
      p_result      out sys_refcursor
   );


    /*
     * Retorna objetos que dependem do objeto atual.
     *
     * Exemplo:
     *
     *   XX_PEDIDO
     *       |
     *       +-- XX_PEDIDO_PKG
     *       +-- XX_PEDIDO_V
     */
   procedure get_dependents (
      p_owner       in varchar2,
      p_object_name in varchar2,
      p_result      out sys_refcursor
   );


    /*
     * Extrai o DDL do objeto através do DBMS_METADATA.
     */
   function get_ddl (
      p_owner       in varchar2,
      p_object_name in varchar2,
      p_object_type in varchar2
   ) return clob;

end xx_cm_change_manager_pkg;
/



create or replace package body xx_cm_change_manager_pkg as


    ----------------------------------------------------------------------
    -- FIND OBJECTS
    ----------------------------------------------------------------------
   procedure find_objects (
      p_owner       in varchar2,
      p_object_name in varchar2 default null,
      p_result      out sys_refcursor
   ) is
   begin
      open p_result for select owner,
                               object_name,
                               object_type,
                               status,
                               created,
                               last_ddl_time
        from all_objects
       where owner = upper(p_owner)
         and ( p_object_name is null
          or object_name like upper(p_object_name) )
       order by object_name,
                object_type;

   end find_objects;



    ----------------------------------------------------------------------
    -- RELATED OBJECTS
    --
    -- Objetos estruturalmente associados ao objeto principal.
    --
    -- TABLE:
    --   INDEX
    --   CONSTRAINT
    --   TRIGGER
    --
    -- PACKAGE:
    --   PACKAGE BODY
    --
    ----------------------------------------------------------------------
   procedure get_related_objects (
      p_owner       in varchar2,
      p_object_name in varchar2,
      p_object_type in varchar2,
      p_result      out sys_refcursor
   ) is
   begin

        ------------------------------------------------------------------
        -- TABLE
        ------------------------------------------------------------------
      if upper(p_object_type) = 'TABLE' then
         open p_result for select 'INDEX' as relation_type,
                                  owner,
                                  index_name as object_name,
                                  index_type as object_type
           from all_indexes
          where table_owner = upper(p_owner)
            and table_name = upper(p_object_name)
         union all
         select 'CONSTRAINT' as relation_type,
                owner,
                constraint_name as object_name,
                constraint_type as object_type
           from all_constraints
          where owner = upper(p_owner)
            and table_name = upper(p_object_name)
         union all
         select 'TRIGGER' as relation_type,
                owner,
                trigger_name as object_name,
                trigger_type as object_type
           from all_triggers
          where table_owner = upper(p_owner)
            and table_name = upper(p_object_name)
          order by relation_type,
                   object_name;


        ------------------------------------------------------------------
        -- PACKAGE
        ------------------------------------------------------------------
      elsif upper(p_object_type) = 'PACKAGE' then
         open p_result for select 'PACKAGE_BODY' as relation_type,
                                  owner,
                                  object_name,
                                  object_type
           from all_objects
          where owner = upper(p_owner)
            and object_name = upper(p_object_name)
            and object_type = 'PACKAGE BODY';


        ------------------------------------------------------------------
        -- TYPE
        ------------------------------------------------------------------
      elsif upper(p_object_type) = 'TYPE' then
         open p_result for select 'TYPE_BODY' as relation_type,
                                  owner,
                                  object_name,
                                  object_type
           from all_objects
          where owner = upper(p_owner)
            and object_name = upper(p_object_name)
            and object_type = 'TYPE BODY';


        ------------------------------------------------------------------
        -- VIEW
        --
        -- No momento não temos uma relação estrutural específica.
        -- Dependências serão tratadas separadamente.
        ------------------------------------------------------------------
      elsif upper(p_object_type) = 'VIEW' then
         open p_result for select 'NONE' as relation_type,
                                  owner,
                                  object_name,
                                  object_type
           from all_objects
          where 1 = 0;


        ------------------------------------------------------------------
        -- OUTROS OBJETOS
        ------------------------------------------------------------------
      else
         open p_result for select 'NONE' as relation_type,
                                  owner,
                                  object_name,
                                  object_type
           from all_objects
          where 1 = 0;

      end if;
   end get_related_objects;



    ----------------------------------------------------------------------
    -- DEPENDENCIES
    --
    -- Objetos que o objeto atual utiliza/referencia.
    --
    -- Exemplo:
    --
    -- XX_PEDIDO_PKG
    --       |
    --       +--> XX_PEDIDO
    --       +--> XX_CLIENTE
    --
    ----------------------------------------------------------------------
   procedure get_dependencies (
      p_owner       in varchar2,
      p_object_name in varchar2,
      p_result      out sys_refcursor
   ) is
   begin
      open p_result for select owner,
                               name,
                               type,
                               referenced_owner,
                               referenced_name,
                               referenced_type
        from all_dependencies
       where owner = upper(p_owner)
         and name = upper(p_object_name)
       order by referenced_owner,
                referenced_name,
                referenced_type;

   end get_dependencies;



    ----------------------------------------------------------------------
    -- DEPENDENTS
    --
    -- Objetos que utilizam/referenciam o objeto atual.
    --
    -- Exemplo:
    --
    -- XX_PEDIDO
    --       ^
    --       |
    --       +--- XX_PEDIDO_PKG
    --       +--- XX_PEDIDO_V
    --
    ----------------------------------------------------------------------
   procedure get_dependents (
      p_owner       in varchar2,
      p_object_name in varchar2,
      p_result      out sys_refcursor
   ) is
   begin
      open p_result for select owner,
                               name,
                               type,
                               referenced_owner,
                               referenced_name,
                               referenced_type
        from all_dependencies
       where referenced_owner = upper(p_owner)
         and referenced_name = upper(p_object_name)
       order by owner,
                name,
                type;

   end get_dependents;



    ----------------------------------------------------------------------
    -- GET DDL
    ----------------------------------------------------------------------
   function get_ddl (
      p_owner       in varchar2,
      p_object_name in varchar2,
      p_object_type in varchar2
   ) return clob is
      l_ddl clob;
   begin
      l_ddl := dbms_metadata.get_ddl(
         upper(p_object_type),
         upper(p_object_name),
         upper(p_owner)
      );

      return l_ddl;
   exception
      when others then
         return '-- Unable to extract DDL: ' || sqlerrm;
   end get_ddl;


end xx_change_manager_pkg;
/