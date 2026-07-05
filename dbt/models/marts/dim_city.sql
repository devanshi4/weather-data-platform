with staged as (

    select * from {{ ref('stg_weather') }}

)

select distinct
    city,
    latitude,
    longitude,
    timezone
from staged