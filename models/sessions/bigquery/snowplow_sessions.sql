{{
    config(
        materialized='table',
        partition_by={
            'field': 'session_start',
            'data_type': 'timestamp'
        },
        enabled=is_adapter('bigquery')
    )
}}

with sessions as (

    select * from {{ ref('snowplow_sessions_tmp') }}

),

id_map as (

    select * from {{ ref('snowplow_id_map') }}

),


stitched as (

    select
        coalesce(id.user_id, s.user_snowplow_domain_id) as inferred_user_id,
        s.*

    from sessions as s
    left outer join id_map as id on s.user_snowplow_domain_id = id.domain_userid

)

select
    * except(session_index),
    row_number() over (partition by inferred_user_id order by session_start) as session_index

from stitched
