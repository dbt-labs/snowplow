
{% macro snowplow_web_events_tmp() %}

    {{ adapter_macro('snowplow.snowplow_web_events_tmp') }}

{% endmacro %}


{% macro default__snowplow_web_events_tmp() %}

{% if var('snowplow:context:web_page', False) %}

{{config(enabled=false)}}

{% else %}

{{
    config(
        materialized='incremental',
        sort='page_view_id',
        dist='page_view_id',
        unique_key='event_id'
    )
}}

with events as (

    select * from {{ var('snowplow:events') }}
    {% if is_incremental() %}
    where collector_tstamp > (
        select coalesce(max(collector_tstamp), '0001-01-01') from {{ this }}
    )
    {% endif %}

),

-- perform page_view_id deduplication directly within events

duplicated as (

    select
    
        event_id

    from events
    group by 1
    having count(distinct page_view_id) > 1

)
    
select * from events
where event_id not in (select event_id from duplicated)

{% endif %}

{% endmacro %}