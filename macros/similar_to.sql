{% macro similar_to(values) %}
  {{ adapter_macro('snowplow.similar_to', values) }}
{% endmacro %}

{% macro default__similar_to(values) %}
    similar to '%({{ values }})%'
{%- endmacro %}

{% macro snowflake__similar_to(values) %}
    rlike '.*({{ values }}).*'
{% endmacro %}
