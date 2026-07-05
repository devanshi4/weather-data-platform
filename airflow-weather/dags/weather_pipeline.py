from airflow import DAG
from airflow.providers.snowflake.operators.snowflake import SQLExecuteQueryOperator
from airflow.operators.bash import BashOperator
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

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command="echo 'STEP 2: Running dbt transformations...'",
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command="echo 'STEP 3: Running dbt tests...'",
    )

    copy_into_snowflake >> dbt_run >> dbt_test