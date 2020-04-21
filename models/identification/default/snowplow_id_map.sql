-- get new events
-- determine most recent mapping between domain_userid and user_id
-- add new & overwrite existing if changed

{{
    config(
        materialized='incremental',
        sort='domain_userid',
        dist='domain_userid',
        unique_key='domain_userid',
        enabled=is_adapter('default')
    )
}}

with all_events as (

    select * from {{ ref('snowplow_web_events') }}

),

new_events as (

    select * from all_events

    {% if is_incremental() %}
        where collector_tstamp > {{get_start_ts(this, 'max_tstamp')}}
    {% endif %}

),

relevant_events as (

    select
        domain_userid,
        user_id,
        collector_tstamp

    from new_events
    where user_id is not null
      and domain_userid is not null
      and collector_tstamp is not null

),

prep as (

    select distinct
        domain_userid,

        last_value(user_id)
            over (partition by domain_userid order by collector_tstamp nulls first rows between unbounded preceding and unbounded following) as user_id,

        max(collector_tstamp)
            over (partition by domain_userid) as max_tstamp

    from relevant_events

),

-- ensure we're not duplicating domain_userid's
dedupe as (

    select *,
        row_number() over (partition by domain_userid order by max_tstamp desc) as idx

    from prep

)

select * from dedupe where idx = 1
