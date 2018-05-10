
{% macro snowplow_web_events_time() %}

    {{ adapter_macro('snowplow.snowplow_web_events_time') }}

{% endmacro %}


{% macro default__snowplow_web_events_time() %}

{{
    config(
        materialized='incremental',
        sort='page_view_id',
        dist='page_view_id',
        sql_where='TRUE',
        unique_key='page_view_id'
    )
}}

{# cache this because we need it below too #}
{% set this_exists = adapter.already_exists(this.schema, this.name) and not flags.FULL_REFRESH%}

with all_events as (

    select * from {{ ref('snowplow_base_events') }}

),

events as (

    select * from all_events
    {% if this_exists %}
    where collector_tstamp > (
        select coalesce(max(max_tstamp), '0001-01-01') from {{ this }}
    )
    {% endif %}

),

web_page_context as (

    select * from {{ ref('snowplow_web_page_context') }}

),


prep as (

    select

        wp.page_view_id,

        min(ev.derived_tstamp) as min_tstamp,
        max(ev.derived_tstamp) as max_tstamp,

        sum(case when ev.event_name = 'page_view' then 1 else 0 end) as pv_count,
        sum(case when ev.event_name = 'page_ping' then 1 else 0 end) as pp_count,
        (sum(case when ev.event_name = 'page_ping' then 1 else 0 end) * {{ var('snowplow:page_ping_frequency', 30) }}) as time_engaged_in_s

    from events as ev
        inner join web_page_context as wp on ev.event_id = wp.root_id

    where ev.event_name in ('page_view', 'page_ping')
    group by 1

),


{% if this_exists %}

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

unioned as (

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

    from unioned
    group by 1


)

{% else %}

-- initial run, don't merge
merged as (

    select * from prep

)

{% endif %}


select * from merged

{% endmacro %}
