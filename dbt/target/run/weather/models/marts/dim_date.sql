
  
    

create or replace transient table WEATHER_DB.ANALYTICS.dim_date
    
    
    
    as (with staged as (

    select * from WEATHER_DB.ANALYTICS.stg_weather

),

dates as (

    select distinct
        date(observed_at) as date_day
    from staged

)

select
    date_day,
    year(date_day)        as year,
    month(date_day)       as month,
    day(date_day)         as day_of_month,
    dayname(date_day)     as day_name
from dates
    )
;


  