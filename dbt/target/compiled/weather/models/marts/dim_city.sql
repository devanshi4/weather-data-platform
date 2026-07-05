with staged as (

    select * from WEATHER_DB.ANALYTICS.stg_weather

)

select distinct
    city,
    latitude,
    longitude,
    timezone
from staged