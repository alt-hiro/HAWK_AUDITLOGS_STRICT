# Snowflake audit log extraction SQL

This directory contains SELECT-only pre-archive validation queries for Snowflake `ACCOUNT_USAGE` audit tables.

## Target tables and extraction periods

| File | Snowflake source table | Extraction period |
| --- | --- | --- |
| `query_history.select.sql` | `SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY` | Last 1 day by `START_TIME` |
| `access_history.select.sql` | `SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY` | Last 1 day by `QUERY_START_TIME` |
| `login_history.select.sql` | `SNOWFLAKE.ACCOUNT_USAGE.LOGIN_HISTORY` | Last 1 day by `EVENT_TIMESTAMP` |
| `sessions.select.sql` | `SNOWFLAKE.ACCOUNT_USAGE.SESSIONS` | Last 1 day by `CREATED_ON` |
| `grants_to_users.select.sql` | `SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS` | Last 1 day by `CREATED_ON` |
| `grants_to_roles.select.sql` | `SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES` | Last 1 day by `CREATED_ON` |
| `grants_to_database_roles.select.sql` | `SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_DATABASE_ROLES` | Last 1 day by `CREATED_ON` |
| `object_dependencies.select.sql` | `SNOWFLAKE.ACCOUNT_USAGE.OBJECT_DEPENDENCIES` | Current snapshot; no time filter |
| `tag_references.select.sql` | `SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES` | Current snapshot; no time filter |
| `warehouse_metering_history.select.sql` | `SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY` | Last 1 day by `START_TIME` |

## Naming rules

Validation SQL files use the following pattern:

```text
sql/<account_usage_table_name_lowercase>.select.sql
```

Internal-stage offload SQL files use the following pattern:

```text
ddls/<account_usage_table_name_lowercase>.copy_into_internal_stage.sql
```

Each offload writes to this internal stage path format:

```text
@HAWK_AUDITLOGS_INTERNAL_STAGE/<TABLE_NAME>/<table_name>_<YYYYMMDDHH24MISS>.csv
```

For example, `QUERY_HISTORY` offloads to a path like:

```text
@HAWK_AUDITLOGS_INTERNAL_STAGE/QUERY_HISTORY/query_history_20260617123456.csv
```

## Query rules

- `*.select.sql` files must contain only `SELECT` statements for pre-archive validation.
- Time-bounded audit tables use `DATEADD(day, -1, CURRENT_TIMESTAMP())`.
- Snapshot-style metadata tables may omit a time filter when the archive requirement is the current state.
- `ddls/init.sql` declares the internal stage used by the offload scripts.
- `ddls/*.copy_into_internal_stage.sql` files use `COPY INTO` to write CSV files to the internal stage.

## Load target deployment SQL

Load-target deployment scripts live under `deply/`:

- `deply/init.sql` creates database `ZSELECT_AUDITLOGS_STRICT`, schema `LOGS`, and CSV file format `ZSELECT_AUDITLOGS_STRICT.LOGS.AUDITLOGS_CSV_FORMAT`.
- `deply/<account_usage_table_name_lowercase>.load.sql` creates `ZSELECT_AUDITLOGS_STRICT.LOGS.<TABLE_NAME>` with `LIKE SNOWFLAKE.ACCOUNT_USAGE.<TABLE_NAME>`.
- Each load script uses `COPY INTO ZSELECT_AUDITLOGS_STRICT.LOGS.<TABLE_NAME>` from `@HAWK_AUDITLOGS_INTERNAL_STAGE/<TABLE_NAME>/` with `MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE`.

Run `deply/init.sql` before running any `deply/*.load.sql` file.
