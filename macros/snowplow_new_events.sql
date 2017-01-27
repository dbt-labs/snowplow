
{% macro select_new_events(from_schema, from_table, tstamp_field) %}

{{ "{% " }} set from_schema = '{{ from_schema }}' {{ "%}" }}
{{ "{% " }} set from_table = '{{ from_table }}' {{ "%}" }}
{{ "{% " }} set tstamp_field = '{{ tstamp_field }}' {{ "%}" }}


select *
from {{ ref('snowplow_base_events') }}

{% raw %}
    {% if already_exists(from_schema, from_table) %}

        where "collector_tstamp" > (select max("{{ tstamp_field }}") from "{{ from_schema }}"."{{ from_table }}")

    {% endif %}
{% endraw %}


{% endmacro %}
