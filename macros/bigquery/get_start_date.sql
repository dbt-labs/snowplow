

{%- macro get_most_recent_record(relation) -%}

    {#-- do not run the query in parsing mode #}
    {%- if not execute -%}
        {{ return('') }}
    {%- endif -%}

    {# fix for tmp suffix #}
    {%- set relation = api.Relation.create(identifier=relation.name, schema=relation.schema) -%}
    {%- set partition_col = config.partition_by.render() -%}

    {%- call statement('_', fetch_result=True) -%}

        select max(partition_col) as start_date from {{ relation }}

    {%- endcall -%}

    {%- set data = load_result('_')['table'].rows -%}
    {{ return(data[0]['start_date']) }}

{%- endmacro -%}



{%- macro get_start_date() -%}

    {%- set start_date -%}

    {%- if config.incremental_strategy == 'insert_overwrite' -%}

        {%- if config.partitions -%} least({{partitions|join(',')}})
        {%- elif config.partition_by.data_type == 'date' -%} _dbt_max_partition
        {%- else -%} date(_dbt_max_partition)
        {%- endif -%}
    
    {%- else -%}
    
        '{{ get_most_recent_record() }}'
    
    {%- endif -%}
    
    {%- endset -%}
    
    {%- do return(start_date) -%}

{%- endmacro -%}