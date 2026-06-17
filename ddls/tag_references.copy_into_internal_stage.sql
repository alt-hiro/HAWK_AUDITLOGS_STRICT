-- Offload SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES to the internal stage.
-- Path format: @HAWK_AUDITLOGS_INTERNAL_STAGE/TAG_REFERENCES/tag_references_<YYYYMMDDHH24MISS>.csv
DECLARE
  archive_path STRING DEFAULT '@HAWK_AUDITLOGS_INTERNAL_STAGE/TAG_REFERENCES/tag_references_'
    || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS')
    || '.csv';
  copy_sql STRING;
BEGIN
  copy_sql :=
    'COPY INTO ' || archive_path || '
     FROM (
       SELECT
         *
       FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES
     )
     FILE_FORMAT = (
       TYPE = CSV
       FIELD_OPTIONALLY_ENCLOSED_BY = ''"''
       COMPRESSION = NONE
       NULL_IF = ('''')
     )
     HEADER = TRUE
     SINGLE = TRUE
     OVERWRITE = FALSE';

  EXECUTE IMMEDIATE copy_sql;
END;
