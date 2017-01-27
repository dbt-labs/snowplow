
{% macro select_new_events(events_table, from_schema, from_table, tstamp_field) %}

{{ "{% " }} set from_schema = '{{ from_schema }}' {{ "%}" }}
{{ "{% " }} set from_table = '{{ from_table }}' {{ "%}" }}
{{ "{% " }} set tstamp_field = '{{ tstamp_field }}' {{ "%}" }}


select *
from {{ ref(events_table) }}

{% raw %}
    {% if already_exists(from_schema, from_table) %}

        where "collector_tstamp" > (select coalesce(max("{{ tstamp_field }}"), '0001-01-01') from "{{ from_schema }}"."{{ from_table }}")

    {% endif %}
{% endraw %}


{% endmacro %}
