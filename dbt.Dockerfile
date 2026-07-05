FROM python:3.12-slim
RUN pip install --no-cache-dir "dbt-snowflake>=1.9,<2.0"
WORKDIR /usr/app/dbt