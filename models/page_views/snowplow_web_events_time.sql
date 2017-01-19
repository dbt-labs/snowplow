
{{
    config(
        materialized='incremental',
        sort='page_view_id',
        dist='page_view_id',
        sql_where='max_tstamp > (select max(max_tstamp) from {{ this }})',
        unique_key='page_view_id'
    )
}}


with web_page_context as (

    select * from {{ ref('snowplow_web_page_context') }}

),

events as (

    select * from {{ ref('snowplow_base_events') }}

),

prep as (

    select

        wp.page_view_id,

        min(ev.derived_tstamp) as min_tstamp,
        max(ev.derived_tstamp) as max_tstamp,

        sum(case when ev.event_name = 'page_view' then 1 else 0 end) as pv_count,
        sum(case when ev.event_name = 'page_ping' then 1 else 0 end) as pp_count,

        -- TODO : make this a variable!
        10 * count(distinct(floor(extract(epoch from ev.derived_tstamp)/10))) - 10 as time_engaged_in_s

    from events as ev
        inner join web_page_context as wp on ev.event_id = wp.root_id

    where ev.event_name in ('page_view', 'page_ping')
    group by 1

)

select * from prep
