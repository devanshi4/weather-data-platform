import json
import os
import datetime
import urllib.request
import boto3

S3_BUCKET = os.environ["S3_BUCKET"]

CITIES = [
    {"name": "chicago",  "latitude": 41.85, "longitude": -87.65},
    {"name": "new_york", "latitude": 40.71, "longitude": -74.01},
    {"name": "denver",   "latitude": 39.74, "longitude": -104.99},
]

API_URL = "https://api.open-meteo.com/v1/forecast"
HOURLY_VARS = "temperature_2m,relative_humidity_2m,wind_speed_10m,precipitation"

s3 = boto3.client("s3")


def fetch_weather(city):
    query = (
        f"{API_URL}?latitude={city['latitude']}&longitude={city['longitude']}"
        f"&hourly={HOURLY_VARS}&timezone=auto&forecast_days=1"
    )
    with urllib.request.urlopen(query, timeout=30) as response:
        return json.loads(response.read())


def upload_to_s3(city_name, data, pull_date):
    key = f"raw/weather/pull_date={pull_date}/city={city_name}.json"
    s3.put_object(Bucket=S3_BUCKET, Key=key, Body=json.dumps(data),
                  ContentType="application/json")
    return key


def handler(event, context):
    pull_date = datetime.date.today().isoformat()
    results = []
    for city in CITIES:
        data = fetch_weather(city)
        key = upload_to_s3(city["name"], data, pull_date)
        results.append(key)
    return {"pull_date": pull_date, "files": results}