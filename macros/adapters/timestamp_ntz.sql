{% macro timestamp_ntz(field) %}
  {{ adapter.dispatch('timestamp_ntz', 'snowplow') (field) }}
{% endmacro %}

{% macro default__timestamp_ntz(field) %}
    {{field}}
{%- endmacro %}

{% macro snowflake__timestamp_ntz(field) %}
    {{field}}::timestamp_ntz
{% endmacro %}
