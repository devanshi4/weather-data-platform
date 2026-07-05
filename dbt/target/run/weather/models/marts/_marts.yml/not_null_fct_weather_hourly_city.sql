
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select city
from WEATHER_DB.ANALYTICS.fct_weather_hourly
where city is null



  
  
      
    ) dbt_internal_test