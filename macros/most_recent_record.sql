

{% macro get_most_recent_record(rel, field, default, precision) %}

    {#-- do not run the query in parsing mode #}
    {% if not execute %}
        {{ return(default) }}
    {% endif %}

    {% if not is_incremental() %}
        {{ return(default) }}
    {% endif %}

    {# fix for tmp suffix #}
    {%- set rel = api.Relation.create(identifier=rel.name, schema=rel.schema) -%}

    {% call statement('_', fetch_result=True) %}

        select coalesce(max({{field}}), '{{ default }}') as ts from {{ rel }}

    {% endcall %}

    {% set data = load_result('_')['table'].rows %}
    
    {{ return(data[0][0]) }}

{% endmacro %}
