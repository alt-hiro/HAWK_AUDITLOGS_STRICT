-- Pre-archive validation query.
-- Source table: SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
-- Extraction period: last 1 day using START_TIME.
-- Naming rule: sql/warehouse_metering_history.select.sql; internal-stage offload SQL: ddls/warehouse_metering_history.copy_into_internal_stage.sql.
SELECT
  *
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE START_TIME >= DATEADD(day, -1, CURRENT_TIMESTAMP());
