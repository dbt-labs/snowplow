
{{ config(materialized='ephemeral') }}

with web_events as (

    select * from {{ ref('snowplow_web_events') }}

),

sessions as (

    select
        domain_sessionid,
        refr_medium,

        row_number() over (partition by domain_sessionid order by dvce_created_tstamp) as page_view_in_session_index,

        last_value(case when refr_medium != 'internal' then domain_sessionid else null end ignore nulls)
            over (partition by domain_userid order by dvce_created_tstamp rows between unbounded preceding and current row) as parent_sessionid

    from web_events

),

mapping as (
    select distinct
        domain_sessionid,
        parent_sessionid
    from sessions
    where refr_medium = 'internal'
      and page_view_in_session_index = 1
      and domain_sessionid is not null
      and parent_sessionid is not null
      and domain_sessionid != parent_sessionid
)

select * from mapping
