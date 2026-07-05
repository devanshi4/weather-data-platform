from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

with DAG(
    dag_id="hello_weather",
    start_date=datetime(2024, 1, 1),
    schedule=None,
    catchup=False,
    tags=["practice"],
) as dag:

    say_hello = BashOperator(
        task_id="say_hello",
        bash_command="echo 'Hello from Airflow!'",
    )

    say_done = BashOperator(
        task_id="say_done",
        bash_command="echo 'Pipeline finished.'",
    )

    say_hello >> say_done