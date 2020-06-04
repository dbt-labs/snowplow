{%- macro convert_timezone(in_tz, out_tz, in_timestamp) -%}
    {{ adapter_macro('convert_timezone', in_tz, out_tz, in_timestamp) }}
{%- endmacro -%}

{% macro default__convert_timezone(in_tz, out_tz, in_timestamp) %}
    convert_timezone({{in_tz}}, {{out_tz}}, {{in_timestamp}})
{% endmacro %}

{% macro postgres__convert_timezone(in_tz, out_tz, in_timestamp) %}
    ({{in_timestamp}} at time zone {{in_tz}} at time zone {{out_tz}})::timestamptz
{% endmacro %}

{% macro spark__convert_timezone(in_tz, out_tz, in_timestamp) %}
    {% if in_tz|lower != "'utc'" %}
        {% do exceptions.raise_compiler_error("Spark can only convert from UTC time") %}
    {% endif %}
    from_utc_timestamp({{in_timestamp}}, {{out_tz}})
{% endmacro %}
