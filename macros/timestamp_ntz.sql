{% macro timestamp_ntz(field) %}
  {{ adapter_macro('snowplow.timestamp_ntz', field) }}
{% endmacro %}

{% macro default__timestamp_ntz(field) %}
    {{field}}
{%- endmacro %}

{% macro snowflake__timestamp_ntz(field) %}
    {{field}}::timestamp_ntz
{% endmacro %}
