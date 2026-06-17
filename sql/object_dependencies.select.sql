-- Pre-archive validation query.
-- Source table: SNOWFLAKE.ACCOUNT_USAGE.OBJECT_DEPENDENCIES
-- Extraction period: current snapshot; no time filter.
-- Naming rule: sql/object_dependencies.select.sql; internal-stage offload SQL: ddls/object_dependencies.copy_into_internal_stage.sql.
SELECT
  *
FROM SNOWFLAKE.ACCOUNT_USAGE.OBJECT_DEPENDENCIES;
