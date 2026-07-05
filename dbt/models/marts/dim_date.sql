with staged as (

    select * from {{ ref('stg_weather') }}

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