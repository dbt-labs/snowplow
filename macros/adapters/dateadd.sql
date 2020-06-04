{% macro dateadd(datepart, interval, from_date_or_timestamp) %}
  {{ adapter_macro('snowplow.dateadd', datepart, interval, from_date_or_timestamp) }}
{% endmacro %}

{% macro default__dateadd(datepart, interval, from_date_or_timestamp) %}
  {{ dbt_utils.dateadd(datepart, interval, from_date_or_timestamp) }}
{% endmacro %}

{% macro spark__dateadd(datepart, interval, from_date_or_timestamp) %}

    {% if datepart == 'day' %}

        date_add(date({{from_date_or_timestamp}}), {{interval}})

    {% elif datepart == 'month' %}

        add_months(date({{from_date_or_timestamp}}), {{interval}})

    {% elif datepart == 'year' %}

        add_months(date({{from_date_or_timestamp}}), {{interval}} * 12)

    {% elif datepart in ('hour', 'minute', 'second') %}

        {%- set multiplier -%} 
            {%- if datepart == 'hour' -%} 3600
            {%- elif datepart == 'minute' -%} 60
            {%- else -%} 1
            {%- endif -%}
        {%- endset -%}

        to_timestamp(
            to_unix_timestamp({{from_date_or_timestamp}})
            + {{interval}} * {{multiplier}}
        )

    {% else %}

        {{ exceptions.raise_compiler_error("macro dateadd not implemented for this datepart on Spark") }}

    {% endif %}

{% endmacro %}