

{% macro snowplow_web_events_tmp() %}

    {{ adapter_macro('snowplow.snowplow_web_events_tmp') }}

{% endmacro %}

{% macro default__snowplow_web_events_tmp() %}

    {{ config(enabled=False) }}

{% endmacro %}

{% macro snowflake__snowplow_web_events_tmp() %}

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

    select * from {{ ref('snowplow_base_events') }}
    {% if is_incremental() %}
    where {{ var('snowplow:partition_col').name }} >= (
        select cast(coalesce(max(collector_tstamp), '0001-01-01') as {{ var('snowplow:partition_col').data_type }}) from {{ this }}
    )
    {% endif %}

),

unnested as (
    
    select
    
        events.*,
        context.value:data.id::varchar as page_view_id
        
    from events, lateral flatten (input => parse_json(contexts):data) context
    where context.value:schema ilike '%/web_page/%'
    
),

-- perform page_view_id deduplication directly within events

duplicated as (

    select
    
        event_id

    from unnested
    group by 1
    having count(distinct page_view_id) > 1

)
    
select * from unnested
where event_id not in (select event_id from duplicated)

{% endif %}

{% endmacro %}