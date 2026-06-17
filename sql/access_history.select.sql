-- Pre-archive validation query.
-- Source table: SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY
-- Extraction period: last 1 day using QUERY_START_TIME.
-- Naming rule: sql/access_history.select.sql; internal-stage offload SQL: ddls/access_history.copy_into_internal_stage.sql.
SELECT
  *
FROM SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY
WHERE QUERY_START_TIME >= DATEADD(day, -1, CURRENT_TIMESTAMP());
