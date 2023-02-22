with source as (

    select * from {{ var('snowplow:events') }}

),

filtered as (

    select 
        *,
        {{ marketing_channel() }} as mkt_channel
    from source


    where true

    {% if var('snowplow:app_ids')|length > 0 %}

    and app_id in (
        {% for app_id in var('snowplow:app_ids') %}
        '{{app_id}}'
        {% if not loop.last %}
        ,
        {% endif %}
        {% endfor %}
    )

    {% endif %}

    --these fields should never be null -- there's a quirk where small numbers of
    --events have made it through without these fields -- ignore these events
    --so as not to throw off downstream models.
        and domain_sessionid is not null
        and domain_sessionidx is not null
        and domain_userid is not null

)

select * from filtered
