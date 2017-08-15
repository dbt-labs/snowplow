
{% macro get_utm_parameter(query_field, utm_param) -%}

nullif(
    split_part(
        split_part({{ query_field }}, '{{ utm_param }}=', 2),
        '&', 1),
    '')

{%- endmacro %}
