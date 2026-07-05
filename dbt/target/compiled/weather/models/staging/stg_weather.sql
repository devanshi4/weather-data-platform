with raw_data as (

    select
        raw_json,
        source_file,
        loaded_at
    from WEATHER_DB.RAW.weather_raw

),

flattened as (

    select
        -- city isn't inside the JSON — we recover it from the file path
        split_part(split_part(raw_data.source_file, 'city=', 2), '.json', 1) as city,

        raw_data.raw_json:latitude::float   as latitude,
        raw_data.raw_json:longitude::float  as longitude,
        raw_data.raw_json:timezone::string  as timezone,
        raw_data.loaded_at as loaded_at,

        -- flatten turns the time array into one row per hour, giving us an index
        each_hour.index                as hour_index,
        each_hour.value::timestamp_ntz as observed_at,

        -- use that index to grab the matching element from each parallel array
        raw_data.raw_json:hourly:temperature_2m[each_hour.index]::float       as temperature_c,
        raw_data.raw_json:hourly:relative_humidity_2m[each_hour.index]::float as humidity_pct,
        raw_data.raw_json:hourly:wind_speed_10m[each_hour.index]::float       as wind_speed,
        raw_data.raw_json:hourly:precipitation[each_hour.index]::float        as precipitation

    from raw_data,
         lateral flatten(input => raw_data.raw_json:hourly:time) as each_hour

)

select * from flattened