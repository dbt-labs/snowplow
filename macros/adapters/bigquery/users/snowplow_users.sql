
{% macro bigquery__snowplow_users() %}

{{
    config(
        materialized='table',
        partition_by='DATE(first_session_start)'
    )
}}


with sessions as (

    select * from {{ ref('snowplow_sessions') }}

),

sessions_agg as (

    select
        inferred_user_id,
        array_agg(sessions order by session_start) as all_sessions

    from sessions
    group by 1

),

sessions_agg_xf as (

    select
        inferred_user_id,
        all_sessions,
        all_sessions[safe_offset(0)] as first_session,
        all_sessions[safe_offset(array_length(all_sessions) - 1)] as last_session

    from sessions_agg

),

users as (

    select
        inferred_user_id,
        first_session.user_snowplow_domain_id,

        array(select distinct user_snowplow_domain_id from unnest(all_sessions)) as domain_userids,

        first_session.session_start as first_session_start,
        last_session.session_end as last_session_end,

        struct(
            first_session.marketing,
            first_session.geo,
            first_session.os,
            first_session.device
        ) as first_touch,

        all_sessions

    from sessions_agg_xf
)

select *
from users

{% endmacro %}
