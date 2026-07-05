
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    weather_key as unique_field,
    count(*) as n_records

from WEATHER_DB.ANALYTICS.fct_weather_hourly
where weather_key is not null
group by weather_key
having count(*) > 1



  
  
      
    ) dbt_internal_test