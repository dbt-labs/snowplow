{% macro create_stage(db_name, s3_url, aws_iam_role) %}

    {%- call statement() -%}
        
        create stage {{db_name}}.snowplow.snowplow_s3 
            url = {{s3_url}} 
            credentials = (aws_role = {{aws_iam_role}})
            file_format = (type = json)
            comment = 'stage for pulling data from snowplow'
        
    {%- endcall -%}   
    
{% endmacro %}