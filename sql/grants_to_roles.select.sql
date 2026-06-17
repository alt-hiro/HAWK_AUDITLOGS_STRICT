-- Pre-archive validation query.
-- Source table: SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
-- Extraction period: last 1 day using CREATED_ON.
-- Naming rule: sql/grants_to_roles.select.sql; internal-stage offload SQL: ddls/grants_to_roles.copy_into_internal_stage.sql.
SELECT
  *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE CREATED_ON >= DATEADD(day, -1, CURRENT_TIMESTAMP());
