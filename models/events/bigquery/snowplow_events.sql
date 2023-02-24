{{
    config(
        materialized='table',
        sort='device_created_timestamp',
        dist='inferred_user_id',
        enabled=is_adapter('bigquery')
    )
}}

with snowplow_events as (

    select *
    from {{ ref('snowplow_events_tmp') }}
    
),


id_map as (

    select * from {{ ref('snowplow_id_map') }}

),


stitched as (

    select
        coalesce(e.user_id, id.user_id, e.user_snowplow_domain_id) as inferred_user_id,
        e.*

    from snowplow_events as e
    left outer join id_map as id on e.user_snowplow_domain_id = id.domain_userid

)

select * from stitched