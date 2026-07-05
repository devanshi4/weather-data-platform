
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    city as unique_field,
    count(*) as n_records

from WEATHER_DB.ANALYTICS.dim_city
where city is not null
group by city
having count(*) > 1



  
  
      
    ) dbt_internal_test