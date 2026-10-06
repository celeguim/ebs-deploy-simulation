-- ============================================================
-- 02_run_edition.sql — Confirmar a run edition
-- ============================================================
-- A edição atual da sessão pode não ser a run edition.
-- A run edition é a edição padrão do database ou a definida
-- pelo EBS no perfil 'APPLICATIONS_EDITION_NAME'.
-- Opção 1: Edição padrão do database
-- 02_run_edition.sql
SELECT
    SYS_CONTEXT ('USERENV', 'CON_NAME') AS container,
    SYS_CONTEXT ('USERENV', 'CURRENT_EDITION_NAME') AS session_edition,
    (
        SELECT
            property_value
        FROM
            database_properties
        WHERE
            property_name = 'DEFAULT_EDITION'
    ) AS default_edition
FROM
    dual;

SELECT
    edition_name,
    parent_edition_name,
    usable
FROM
    dba_editions
ORDER BY
    edition_name;