{% macro similar_to(string) %}
  {{ adapter_macro('snowplow.similar_to', string) }}
{% endmacro %}

{% macro default__similar_to(string) %}
    similar to "'%"{{string}}"%'" 
{%- endmacro %}

{% macro snowflake__similar_to(string) %}
    rlike "'.*"{{string}}".*'"
{% endmacro %}
