
{%- macro get_max_sql(relation, field = 'collector_tstamp') -%}

    select
        
        coalesce(
            max({{field}}), 
            '0001-01-01'    -- a long, long time ago
        ) as start_ts
        
    from {{ relation }}

{%- endmacro -%}


{%- macro get_most_recent_record(relation, field = 'collector_tstamp') -%}

    {%- set result = run_query(get_max_sql(relation, field)) -%}
    
    {% if execute %}
        {% set start_ts = result.columns['start_ts'].values()[0] %}
    {% else %}
        {% set start_ts = '' %}
    {% endif %}

    {{ return(start_ts) }}

{%- endmacro -%}


{%- macro get_start_ts(relation, field = 'collector_tstamp') -%}
    {{ adapter.dispatch('get_start_ts', 'snowplow')(relation, field) }}
{%- endmacro -%}


{%- macro default__get_start_ts(relation, field = 'collector_tstamp') -%}
    ({{get_max_sql(relation, field)}})
{%- endmacro -%}


{%- macro bigquery__get_start_ts(relation, field = 'collector_tstamp') -%}

    {%- set partition_by = config.get('partition_by', none) -%}
    {%- set partitions = config.get('partitions', none) -%}
    
    {%- set start_ts -%}
        {%- if config.incremental_strategy == 'insert_overwrite' -%}

            {%- if partitions -%} least({{partitions|join(',')}})
            {%- elif partition_by.data_type == 'date' -%} _dbt_max_partition
            {%- else -%} date(_dbt_max_partition)
            {%- endif -%}
        
        {%- else -%}
        
            {%- set rendered -%}
                {%- if partition_by.data_type == 'date' -%} {{partition_by.field}}
                {%- else -%} date({{partition_by.field}}) {%- endif -%}
            {%- endset -%}
            {%- set record = get_most_recent_record(relation, rendered) -%}
            '{{record}}'
        
        {%- endif -%}
    {%- endset -%}
    
    {%- do return(start_ts) -%}

{%- endmacro -%}