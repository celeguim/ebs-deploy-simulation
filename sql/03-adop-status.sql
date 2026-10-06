-- 03_adop_status.sql
-- Últimas sessões, todas as fases e datas
SELECT
    adop_session_id,
    node_type,
    "node_name#1" AS node_name,
    edition_name,
    status,
    prepare_status,
    apply_status,
    finalize_status,
    cutover_status,
    cleanup_status,
    abort_status,
    abandon_flag,
    prepare_start_date,
    apply_start_date,
    cutover_start_date,
    cutover_end_date,
    cleanup_end_date,
    abort_end_date
FROM
    ad_adop_sessions
ORDER BY
    adop_session_id DESC,
    node_type,
    "node_name#1"
FETCH FIRST
    6 ROWS ONLY;

-- Sessões que não estão no mesmo estado final da sessão 426
-- (você mostrou antes: Y Y Y Y Y X C). Resultado vazio é um bom sinal,
-- mas é apenas um indício.
SELECT
    adop_session_id,
    "node_name#1" AS node_name,
    status,
    prepare_status,
    apply_status,
    finalize_status,
    cutover_status,
    cleanup_status,
    abort_status
FROM
    ad_adop_sessions
WHERE
    adop_session_id = (
        SELECT
            MAX(adop_session_id)
        FROM
            ad_adop_sessions
    )
    AND status <> 'C';