
{% macro get_utm_parameter(query_field, utm_param) -%}

nullif(
    split_part(
        split_part(({{ query_field }})::text, '{{ utm_param }}='::text, 2),
        '&'::text, 1),
    '')

{%- endmacro %}
