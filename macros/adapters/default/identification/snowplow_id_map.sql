
{% macro snowplow_id_map() %}

    {{ adapter_macro('snowplow.snowplow_id_map') }}

{% endmacro %}


{% macro default__snowplow_id_map() %}

-- get new events
-- determine most recent mapping between domain_userid and user_id
-- add new & overwrite existing if changed

{{
    config(
        materialized='incremental',
        sort='domain_userid',
        dist='domain_userid',
        sql_where='TRUE',
        unique_key='domain_userid'
    )
}}

with all_events as (

    select * from {{ ref('snowplow_web_events') }}

),

new_events as (

    select *
    from all_events

    {% if adapter.already_exists(this.schema, this.name) and not flags.FULL_REFRESH %}
    where collector_tstamp > (
        select coalesce(max(max_tstamp), '0001-01-01') from {{ this }}
    )
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

{% endmacro %}
