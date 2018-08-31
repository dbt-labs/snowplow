

{% macro get_most_recent_record(rel, field, default) %}

    {#-- do not run the query in parsing mode #}
    {% if not execute %}
        {{ return(default) }}
    {% endif %}

    {% if not adapter.already_exists(rel.schema, rel.name) or flags.FULL_REFRESH %}
        {{ return(default) }}
    {% endif %}

    {# fix for tmp suffix #}
    {%- set rel = api.Relation.create(identifier=rel.name, schema=rel.schema) -%}

    {% call statement('_', fetch_result=True) %}

        select cast(coalesce(max({{field}}), '{{ default }}') as date) as ts from {{ rel }}

    {% endcall %}

    {% set data = load_result('_')['table'].rows %}
    {{ return(data[0]['ts']) }}

{% endmacro %}
