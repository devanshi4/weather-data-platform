-- back compat for old kwarg name
  
  begin;
    
        
            
            
            
            
        
    

    

    merge into WEATHER_DB.ANALYTICS.fct_weather_hourly as DBT_INTERNAL_DEST
        using WEATHER_DB.ANALYTICS.fct_weather_hourly__dbt_tmp as DBT_INTERNAL_SOURCE
        on ((DBT_INTERNAL_SOURCE.weather_key = DBT_INTERNAL_DEST.weather_key))

    
    when matched then update set
        "WEATHER_KEY" = DBT_INTERNAL_SOURCE."WEATHER_KEY","CITY" = DBT_INTERNAL_SOURCE."CITY","DATE_DAY" = DBT_INTERNAL_SOURCE."DATE_DAY","OBSERVED_AT" = DBT_INTERNAL_SOURCE."OBSERVED_AT","LOADED_AT" = DBT_INTERNAL_SOURCE."LOADED_AT","TEMPERATURE_C" = DBT_INTERNAL_SOURCE."TEMPERATURE_C","HUMIDITY_PCT" = DBT_INTERNAL_SOURCE."HUMIDITY_PCT","WIND_SPEED" = DBT_INTERNAL_SOURCE."WIND_SPEED","PRECIPITATION" = DBT_INTERNAL_SOURCE."PRECIPITATION"
    

    when not matched then insert
        ("WEATHER_KEY", "CITY", "DATE_DAY", "OBSERVED_AT", "LOADED_AT", "TEMPERATURE_C", "HUMIDITY_PCT", "WIND_SPEED", "PRECIPITATION")
    values
        ("WEATHER_KEY", "CITY", "DATE_DAY", "OBSERVED_AT", "LOADED_AT", "TEMPERATURE_C", "HUMIDITY_PCT", "WIND_SPEED", "PRECIPITATION")

;
    commit;