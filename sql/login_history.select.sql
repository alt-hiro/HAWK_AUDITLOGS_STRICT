-- Pre-archive validation query.
-- Source table: SNOWFLAKE.ACCOUNT_USAGE.LOGIN_HISTORY
-- Extraction period: last 1 day using EVENT_TIMESTAMP.
-- Naming rule: sql/login_history.select.sql; internal-stage offload SQL: ddls/login_history.copy_into_internal_stage.sql.
SELECT
  *
FROM SNOWFLAKE.ACCOUNT_USAGE.LOGIN_HISTORY
WHERE EVENT_TIMESTAMP >= DATEADD(day, -1, CURRENT_TIMESTAMP());
