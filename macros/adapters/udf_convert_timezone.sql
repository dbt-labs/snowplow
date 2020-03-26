{%- macro create_udf_convert_timezone() -%}
    {{ adapter_macro('create_udf_convert_timezone') }}
{%- endmacro -%}

{% macro default__create_udf_convert_timezone() %}
    select 1 as fun -- noop
{% endmacro %}

{% macro postgres__create_udf_convert_timezone() %}
    create or replace function convert_timezone(
        in_tzname text,
        out_tzname text,
        in_t timestamptz
        ) returns timestamptz
    as $$
    declare
    begin
      return in_t at time zone out_tzname at time zone in_tzname;
    end;
    $$ language plpgsql;
{% endmacro %}
