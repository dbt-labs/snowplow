{% if var('snowplow:context:web_page') %}

select * from {{ var('snowplow:context:web_page') }}

{% else %}

{{ config(enabled=False) }}

{% endif %}