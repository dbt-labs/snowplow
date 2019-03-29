{% macro create_snowplow_schema(db_name) %}

    {%- call statement() -%}
        
        create schema if not exists {{db_name}}.snowplow
        
    {%- endcall -%}   
    
{% endmacro %}