{{
    config(
        materialized='incremental',
        unique_key='weather_key'
    )
}}

with staged as (

    select * from {{ ref('stg_weather') }}

    {% if is_incremental() %}

    -- on incremental runs, only pull rows newer than what we already have
    where loaded_at > (select max(loaded_at) from {{ this }})

    {% endif %}

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
    from staged
    qualify row_number() over (
        partition by city, observed_at
        order by loaded_at desc
    ) = 1

)

select * from deduplicated
