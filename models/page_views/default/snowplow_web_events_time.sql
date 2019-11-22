{{
    config(
        materialized='incremental',
        sort='page_view_id',
        dist='page_view_id',
        unique_key='page_view_id',
        enabled=is_adapter('default')
    )
}}


with events as (

    select * from ({{ snowplow_web_events_tmp() }})

),

prep as (

    select

        page_view_id,

        min({{snowplow.timestamp_ntz('derived_tstamp')}}) as min_tstamp,
        max({{snowplow.timestamp_ntz('derived_tstamp')}}) as max_tstamp,

        sum(case when event_name = 'page_view' then 1 else 0 end) as pv_count,
        sum(case when event_name = 'page_ping' then 1 else 0 end) as pp_count,
        (sum(case when event_name = 'page_ping' then 1 else 0 end) * {{ var('snowplow:page_ping_frequency', 30) }}) as time_engaged_in_s

    from events

    where event_name in ('page_view', 'page_ping')
    group by 1

),


{% if is_incremental() %}

relevant_existing as (

    select
        page_view_id,
        min_tstamp,
        max_tstamp,
        pv_count,
        pp_count,
        time_engaged_in_s

    from {{ this }}
    where page_view_id in (select page_view_id from prep)

),

unioned_cte as (

    select
        page_view_id,
        min_tstamp,
        max_tstamp,
        pv_count,
        pp_count,
        time_engaged_in_s
    from prep

    union all

    select
        page_view_id,
        min_tstamp, 
        max_tstamp,
        pv_count,
        pp_count,
        time_engaged_in_s
    from relevant_existing

),

merged as (

    select
        page_view_id,
        min(min_tstamp) as min_tstamp,
        max(max_tstamp) as max_tstamp,
        sum(pv_count) as pv_count,
        sum(pp_count) as pp_count,
        sum(time_engaged_in_s) as time_engaged_in_s

    from unioned_cte
    group by 1


)

{% else %}

-- initial run, don't merge
merged as (

    select * from prep

)

{% endif %}


select * from merged