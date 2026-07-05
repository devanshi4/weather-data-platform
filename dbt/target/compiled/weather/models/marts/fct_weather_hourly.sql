

with staged as (

    select * from WEATHER_DB.ANALYTICS.stg_weather

),



-- the newest loaded_at already sitting in this table (the watermark)
current_max as (

    select max(loaded_at) as max_loaded_at
    from WEATHER_DB.ANALYTICS.fct_weather_hourly

),

new_rows as (

    select staged.*
    from staged
    cross join current_max
    where staged.loaded_at > current_max.max_loaded_at

),



deduplicated as (

    select
        md5(city || '-' || observed_at)  as weather_key,

        city                             as city,
        date(observed_at)                as date_day,
        observed_at,
        loaded_at,

        temperature_c,
        humidity_pct,
        wind_speed,
        precipitation
    from new_rows
    qualify row_number() over (
        partition by city, observed_at
        order by loaded_at desc
    ) = 1

)

select * from deduplicated