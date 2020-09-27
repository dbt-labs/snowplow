{{config(enabled=snowplow.is_adapter('bigquery'))}}

{# handle the fact that we can't seed nulls to bigquery #}
{%- set cols = adapter.get_columns_in_relation(ref('sp_event')) -%}
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

select {{col_list_csv}} from {{ ref('sp_event') }}

{% if var('update', False) %}

    union all

    select {{col_list_csv}} from {{ ref('sp_event_update') }}

{% endif %}
