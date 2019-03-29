{% macro create_pipe(s3_url, aws_iam_role, db_name='raw', grant_to_role='transformer') %}
    
    {% create_snowplow_schema(db_name) %}
    {% create_snowplow_events_table(db_name) %}
    {% create_stage(db_name, s3_url, aws_iam_role) %}
    {% create_pipe(db_name) %}
    
    {%- call statement() -%}
    
        grant usage on schema snowplow to role {{grant_to_role}};

        grant select on all tables in schema snowplow to role {{grant_to_role}};
        
    {%- endcall -%}   

{% endmacro %}