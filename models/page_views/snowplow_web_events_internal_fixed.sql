
{{ config(materialized='ephemeral') }}

-- "ignore nulls" doesn't work on postgres. TODO; do this another way
{% set ignore_nulls = ('' if target.type == 'postgres' else 'ignore nulls') %}

with web_events as (

    select * from {{ ref('snowplow_web_events') }}

),

sessions as (

    select
        domain_sessionid,
        refr_medium,

        row_number() over (partition by domain_sessionid order by dvce_created_tstamp) as page_view_in_session_index,

        last_value(case when refr_medium != 'internal' then domain_sessionid else null end {{ ignore_nulls }})
            over (partition by domain_userid order by dvce_created_tstamp rows between unbounded preceding and current row) as parent_sessionid,

        last_value(refr_urlquery {{ ignore_nulls }})
            over (partition by domain_userid order by dvce_created_tstamp rows between unbounded preceding and current row) as parent_urlquery

    from web_events

),

mapping as (
    select distinct
        domain_sessionid,
        parent_sessionid,

        parent_urlquery,
        {{ snowplow.get_utm_parameter('parent_urlquery', 'utm_source') }} as utm_source,
        {{ snowplow.get_utm_parameter('parent_urlquery', 'utm_medium') }} as utm_medium,
        {{ snowplow.get_utm_parameter('parent_urlquery', 'utm_campaign') }} as utm_campaign,
        {{ snowplow.get_utm_parameter('parent_urlquery', 'utm_content') }} as utm_content,
        {{ snowplow.get_utm_parameter('parent_urlquery', 'utm_term') }} as utm_term

    from sessions
    where refr_medium = 'internal'
      and page_view_in_session_index = 1
      and domain_sessionid is not null
      and (domain_sessionid != parent_sessionid or parent_sessionid is null)

)

select * from mapping
