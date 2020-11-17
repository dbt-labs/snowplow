{{
    config(
        materialized='incremental',
        sort=['platform','event_name'],
        dist='sequence_number',
        sql_where='TRUE',
        unique_key='sequence_number',
        primary_key='sequence_number'
    )
}}

with source as (

    select * from {{ref('sp_base_events_fivetran')}}
    {% if adapter.already_exists(this.schema, this.name) and not flags.FULL_REFRESH %}
    where collector_tstamp > (
        select coalesce(max(collector_tstamp), '0001-01-01') from {{ this }}
    )
    {% endif %}
),

filtered as (

    select *
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

    --these fields should never be null; there's a quirk where small numbers of
    --events have made it through without these fields; ignore these events
    --so as not to throw off downstream models.
        and domain_sessionid is not null
        and domain_sessionidx is not null
        and domain_userid is not null

)

select * from filtered
