import json
import datetime
import requests
import boto3

from dotenv import load_dotenv
import os
load_dotenv()


S3_BUCKET = os.getenv("S3_BUCKET")
AWS_REGION = os.getenv("AWS_REGION")

CITIES = [
    {"name": "chicago",  "latitude": 41.85, "longitude": -87.65},
    {"name": "new_york", "latitude": 40.71, "longitude": -74.01},
    {"name": "denver",   "latitude": 39.74, "longitude": -104.99},
]

API_URL = "https://api.open-meteo.com/v1/forecast"
HOURLY_VARS = "temperature_2m,relative_humidity_2m,wind_speed_10m,precipitation"

s3 = boto3.client("s3", region_name = AWS_REGION)

def fetch_weather(city):

    params = {
        "latitude" : city["latitude"],
        "longitude" : city["longitude"],
        "hourly" : HOURLY_VARS,
        "timezone" : "auto",
        "forecast_days" : 1
    }

    response = requests.get(API_URL, params = params, timeout = 30)
    response.raise_for_status()
    return response.json()

def upload_to_s3(city_name, data, pull_date):
    key = f"raw/weather/pull_date={pull_date}/city={city_name}.json"
    body = json.dumps(data)
    s3.put_object(
        Bucket = S3_BUCKET,
        Key = key,
        Body = body,
        ContentType = "application/json",
    )
    return key



def main():
    pull_date = datetime.date.today().isoformat()
    print(f"Starting weather pull for {pull_date}")
    for city in CITIES:

        try:
            data = fetch_weather(city)
            key = upload_to_s3(city["name"], data, pull_date)
            print(f" OK {city['name']} just landed in : s3://{S3_BUCKET}/{key}")

        except Exception as error:
            print(f" FAIL{city['name']} : {error}")
    print("DONE.")


if __name__ == "__main__":
    main()




        


