{{config(enabled=snowplow.is_adapter('default'))}}

select * from {{ ref('sp_event') }}

{% if var('update', False) %}

    union all

    select * from {{ ref('sp_event_update') }}

{% endif %}
