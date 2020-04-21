{{
    config(
        materialized='incremental',
        sort='page_view_id',
        dist='page_view_id',
        unique_key='page_view_id',
        enabled=is_adapter('default')
    )
}}


with all_events as (

    select * from {{ ref('snowplow_base_events') }}

),

events as (

    select * from all_events
    
    {% if is_incremental() %}
        where collector_tstamp > {{get_start_ts(this, 'max_tstamp')}}
    {% endif %}

),

web_page_context as (

    select * from {{ ref('snowplow_web_page_context') }}

),


prep as (

    select

        wp.page_view_id,

        min({{snowplow.timestamp_ntz('ev.derived_tstamp')}}) as min_tstamp,
        max({{snowplow.timestamp_ntz('ev.derived_tstamp')}}) as max_tstamp,

        sum(case when ev.event_name = 'page_view' then 1 else 0 end) as pv_count,
        sum(case when ev.event_name = 'page_ping' then 1 else 0 end) as pp_count,
        (sum(case when ev.event_name = 'page_ping' then 1 else 0 end) * {{ var('snowplow:page_ping_frequency', 30) }}) as time_engaged_in_s

    from events as ev
        inner join web_page_context as wp on ev.event_id = wp.root_id

    where ev.event_name in ('page_view', 'page_ping')
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