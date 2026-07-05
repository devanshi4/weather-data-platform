
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select weather_key
from WEATHER_DB.ANALYTICS.fct_weather_hourly
where weather_key is null



  
  
      
    ) dbt_internal_test