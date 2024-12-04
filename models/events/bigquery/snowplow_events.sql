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

),

numbered as (

      select
          *,
          row_number() over (
              partition by inferred_user_id, event_category, event_action, event_label
              order by device_created_timestamp, device_sent_timestamp
          ) as nth_event_asc,

          row_number() over (
              partition by inferred_user_id, event_category, event_action, event_label
              order by device_created_timestamp desc, device_sent_timestamp desc
          ) as nth_event_desc

      from stitched
)

select * from numbered