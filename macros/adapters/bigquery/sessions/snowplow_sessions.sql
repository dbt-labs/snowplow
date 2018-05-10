
{% macro bigquery__snowplow_sessions() %}

{{
    config(
        materialized='table',
        partition_by='DATE(session_start)'
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

{% endmacro %}
