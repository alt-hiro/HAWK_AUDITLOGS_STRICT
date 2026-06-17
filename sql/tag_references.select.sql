-- Pre-archive validation query.
-- Source table: SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES
-- Extraction period: current snapshot; no time filter.
-- Naming rule: sql/tag_references.select.sql; internal-stage offload SQL: ddls/tag_references.copy_into_internal_stage.sql.
SELECT
  *
FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES;
