
{%- if var('snowplow:context:web_page', False) -%}
    {%- set base, update = ref('sp_event'), ref('sp_event_update') -%}
{%- else -%}
    {%- set base, update = ref('canonical_event'), ref('canonical_event_update') -%}
{%- endif -%}

{%- if target.type == 'bigquery' -%}

    {# handle the fact that we can't seed nulls to bigquery #}
    {%- set cols = adapter.get_columns_in_relation(base) -%}
    {%- set col_list = [] -%}

    {%- for col in cols -%}
        {%- set col_statement -%}
        {%- if col.data_type == 'STRING' %}
        nullif({{col.column}},'NULL') as {{col.column}}
        {% else %}
        {{col.column}}
        {% endif -%}
        {%- endset -%}
        {%- do col_list.append(col_statement) -%}
    {%- endfor -%}

    {%- set col_list_csv = col_list|join(',') -%}
    
{%- elif target.type == 'snowflake' and not var('snowplow:context:web_page', False) -%}
    
    {%- set col_list_csv = dbt_utils.star(base, except=['PAGE_VIEW_ID']) -%}
    
{%- else -%}

    {%- set col_list_csv = '*' -%}

{%- endif -%}



{%- if var('snowplow:context:web_page', False) -%}

    select {{col_list_csv}} from {{ base }}

    {%- if var('update', False) %}

        union all

        select {{col_list_csv}} from {{ update }}

    {% endif %}

{%- else -%}

    select {{col_list_csv}} from {{ base }}

    {% if var('update', False) %}

        union all

        select {{col_list_csv}} from {{ update }}

    {% endif %}

{%- endif -%}
