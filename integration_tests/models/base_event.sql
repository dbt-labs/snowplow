
select * from {{ ref('event') }}

{% if var('update', False) %}

    union all

    select * from {{ ref('event_update') }}

{% endif %}
