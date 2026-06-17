-- Pre-archive validation query.
-- Source table: SNOWFLAKE.ACCOUNT_USAGE.SESSIONS
-- Extraction period: last 1 day using CREATED_ON.
-- Naming rule: sql/sessions.select.sql; internal-stage offload SQL: ddls/sessions.copy_into_internal_stage.sql.
SELECT
  *
FROM SNOWFLAKE.ACCOUNT_USAGE.SESSIONS
WHERE CREATED_ON >= DATEADD(day, -1, CURRENT_TIMESTAMP());
