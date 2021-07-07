{%- macro convert_timezone(in_tz, out_tz, in_timestamp) -%}
    {{ adapter.dispatch('convert_timezone', 'snowplow')(in_tz, out_tz, in_timestamp) }}
{%- endmacro -%}

{% macro default__convert_timezone(in_tz, out_tz, in_timestamp) %}
    convert_timezone({{in_tz}}, {{out_tz}}, {{in_timestamp}})
{% endmacro %}

{% macro postgres__convert_timezone(in_tz, out_tz, in_timestamp) %}
    ({{in_timestamp}} at time zone {{in_tz}} at time zone {{out_tz}})::timestamptz
{% endmacro %}
