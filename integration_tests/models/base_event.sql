{% if var('snowplow:context:web_page', False) %}

    select * from {{ ref('event') }}

    {% if var('update', False) %}

        union all

        select * from {{ ref('event_update') }}

    {% endif %}

{% else %}

    select * from {{ ref('canonical_event') }}

    {% if var('update', False) %}

        union all

        select * from {{ ref('canonical_event_update') }}

    {% endif %}

{% endif %}