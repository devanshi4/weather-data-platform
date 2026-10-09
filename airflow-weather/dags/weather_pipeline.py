from airflow import DAG
from airflow.providers.snowflake.operators.snowflake import SQLExecuteQueryOperator
from datetime import datetime

COPY_INTO_SQL = """
COPY INTO WEATHER_DB.RAW.WEATHER_RAW (raw_json, source_file)
  FROM (
    SELECT $1, METADATA$FILENAME
    FROM @WEATHER_DB.RAW.WEATHER_STAGE
  )
  FILE_FORMAT = (TYPE = 'JSON')
  ON_ERROR = 'ABORT_STATEMENT';
"""

# Loads the day's raw JSON files from the S3 external stage into Snowflake.
# dbt transformations run separately from the dbt container (see README).
with DAG(
    dag_id="weather_pipeline",
    start_date=datetime(2024, 1, 1),
    schedule="@daily",
    catchup=False,
    tags=["weather", "production"],
) as dag:

    copy_into_snowflake = SQLExecuteQueryOperator(
        task_id="copy_into_snowflake",
        conn_id="snowflake_default",
        sql=COPY_INTO_SQL,
    )
