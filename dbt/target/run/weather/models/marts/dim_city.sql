
  
    

create or replace transient table WEATHER_DB.ANALYTICS.dim_city
    
    
    
    as (with staged as (

    select * from WEATHER_DB.ANALYTICS.stg_weather

)

select distinct
    city,
    latitude,
    longitude,
    timezone
from staged
    )
;


  