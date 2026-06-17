# HAWK_AUDITLOGS_STRICT

## 目的

このリポジトリは、監査対応のために Snowflake の監査ログ系データを退避・保管する仕組みを管理するためのものです。

主な目的は、Snowflake の `SNOWFLAKE.ACCOUNT_USAGE` にある特定テーブルのデータを差分抽出し、監査要件を満たす Amazon S3 へ退避できる状態にすることです。

## 想定アーキテクチャ

現時点の実装方針は、Snowflake から Amazon S3 へ直接退避するのではなく、以下の段階的な流れを想定しています。

1. `SNOWFLAKE.ACCOUNT_USAGE` の対象テーブルを確認用 `SELECT` で検証する。
2. 対象テーブルの差分データを Snowflake の内部ステージへ `COPY INTO` で CSV 出力する。
3. 内部ステージ上の CSV を Amazon S3 へ移動する。
4. 必要に応じて、退避済み CSV を Snowflake 側のロード先テーブルへ再ロードして検証・参照できるようにする。

```text
SNOWFLAKE.ACCOUNT_USAGE
  -> SELECT validation SQL
  -> COPY INTO internal stage
  -> Lambda moves files to audit-ready Amazon S3
  -> optional reload into ZSELECT_AUDITLOGS_STRICT.LOGS
```

## 実行方式の想定

### Snowflake 内部ステージへの退避

対象テーブルの内部ステージ退避は、Snowflake の `COPY INTO` 句で実行します。

将来的には Snowflake Task で定期実行する想定ですが、現時点では Task 定義はまだ作成していません。現在のリポジトリには、Task から呼び出す候補となる SQL ファイルを配置しています。

### 内部ステージから Amazon S3 への移動

内部ステージから監査対応済み Amazon S3 への移動は、AWS Lambda で実装する想定です。

Snowflake から Amazon S3 へ直接 `COPY` できる構成にできればより単純ですが、現時点ではその実装方法を確定していないため、まずは内部ステージを中継地点として扱います。

## ディレクトリ構成

| Path | 役割 |
| --- | --- |
| `sql/` | 退避前の確認用 `SELECT` SQL を配置します。 |
| `ddls/` | Snowflake 内部ステージ作成 SQL と、内部ステージへ CSV 出力する `COPY INTO` SQL を配置します。 |
| `deply/` | 退避 CSV のロード先となる Snowflake データベース・スキーマ・テーブル作成 SQL と、内部ステージからロード先テーブルへ取り込む `COPY INTO` SQL を配置します。 |

## 対象テーブル

現在の退避対象は以下の `SNOWFLAKE.ACCOUNT_USAGE` テーブルです。

- `QUERY_HISTORY`
- `ACCESS_HISTORY`
- `LOGIN_HISTORY`
- `SESSIONS`
- `GRANTS_TO_USERS`
- `GRANTS_TO_ROLES`
- `GRANTS_TO_DATABASE_ROLES`
- `OBJECT_DEPENDENCIES`
- `TAG_REFERENCES`
- `WAREHOUSE_METERING_HISTORY`

## ファイル命名規則

### 確認用 SELECT SQL

```text
sql/<account_usage_table_name_lowercase>.select.sql
```

例:

```text
sql/query_history.select.sql
sql/access_history.select.sql
```

### 内部ステージ退避 SQL

```text
ddls/<account_usage_table_name_lowercase>.copy_into_internal_stage.sql
```

内部ステージの出力パスは以下の形式です。

```text
@HAWK_AUDITLOGS_INTERNAL_STAGE/<TABLE_NAME>/<table_name>_<YYYYMMDDHH24MISS>.csv
```

例:

```text
@HAWK_AUDITLOGS_INTERNAL_STAGE/QUERY_HISTORY/query_history_20260617123456.csv
```

### ロード先テーブル作成・ロード SQL

```text
deply/<account_usage_table_name_lowercase>.load.sql
```

ロード先は以下の database / schema を使用します。

```text
ZSELECT_AUDITLOGS_STRICT.LOGS
```

## 初期化 SQL

### 内部ステージ

`ddls/init.sql` で、Snowflake 内部ステージ `HAWK_AUDITLOGS_INTERNAL_STAGE` を作成します。

### ロード先 database / schema

`deply/init.sql` で、ロード先の database / schema と CSV ロード用 file format を作成します。

- Database: `ZSELECT_AUDITLOGS_STRICT`
- Schema: `LOGS`
- File format: `ZSELECT_AUDITLOGS_STRICT.LOGS.AUDITLOGS_CSV_FORMAT`

## 開発者向けの実行順序

1. `sql/*.select.sql` を実行し、抽出対象の件数や内容を確認する。
2. `ddls/init.sql` を実行し、内部ステージを作成する。
3. `ddls/*.copy_into_internal_stage.sql` を実行し、対象テーブルを内部ステージへ CSV 出力する。
4. Lambda 実装後、内部ステージ上の CSV を監査対応済み Amazon S3 へ移動する。
5. Snowflake 側に退避 CSV をロードして確認したい場合は、`deply/init.sql` を実行したうえで `deply/*.load.sql` を実行する。

## 未実装・今後の作業

- Snowflake Task による定期実行定義の追加。
- 内部ステージから Amazon S3 へ移動する Lambda の実装。
- Amazon S3 側のバケット、プレフィックス、暗号化、ライフサイクル、監査要件の確定。
- Snowflake から Amazon S3 へ直接退避する方式の調査。
- 差分抽出期間や保持期間のプロジェクト要件に合わせた最終調整。
