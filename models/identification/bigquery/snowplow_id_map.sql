-- get new events
-- determine most recent mapping between domain_userid and user_id
-- add new & overwrite existing if changed

{{
    config(
        materialized='incremental',
        partition_by='DATE(max_tstamp)',
        unique_key="domain_userid",
        enabled=is_adapter('bigquery')
    )
}}

{% set start_date = get_most_recent_record(this, "max_tstamp", "2001-01-01") %}

with all_events as (

    select *
    from {{ ref('snowplow_base_events') }}
    where DATE(collector_tstamp) >= date_sub(date('{{ start_date }}'), interval 1 day)

),

new_sessions as (

    select distinct
        domain_sessionid

    from all_events
    where DATE(collector_tstamp) >= date('{{ start_date }}')

),

relevant_events as (

    select
        domain_userid,
        cast(user_id as string) as user_id,
        collector_tstamp

    from all_events
    where domain_sessionid in (select distinct domain_sessionid from new_sessions)
      and user_id is not null
      and domain_userid is not null
      and collector_tstamp is not null


),

prep as (

    select distinct

        domain_userid,

        last_value(user_id ignore nulls) over (
            partition by domain_userid
            order by collector_tstamp
            rows between unbounded preceding and unbounded following
        ) as user_id,

        max(timestamp(collector_tstamp)) over (
            partition by domain_userid
        ) as max_tstamp

    from relevant_events

),

-- ensure we're not duplicating domain_userid's
dedupe as (

    select *,
        row_number() over (partition by domain_userid order by max_tstamp desc) as idx

    from prep

)

select * from dedupe where idx = 1
