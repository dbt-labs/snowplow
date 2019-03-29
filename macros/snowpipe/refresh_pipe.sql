{% macro refresh_pipe(pipe_name) %}

    {%- call statement('alter_pipe', fetch_result=True) -%}
        
        alter pipe {{pipe_name}} refresh
        
    {%- endcall -%}     
        
    {%- if execute -%}

        {%- set results = load_result('alter_pipe').table.print_table(max_column_width = 125, max_rows = 30) -%}

    {%- else -%}

        {%- set results = [] -%}
        
    {%- endif -%}
          
{% endmacro %}