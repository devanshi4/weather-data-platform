
    
    

with child as (
    select city as from_field
    from WEATHER_DB.ANALYTICS.fct_weather_hourly
    where city is not null
),

parent as (
    select city as to_field
    from WEATHER_DB.ANALYTICS.dim_city
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


