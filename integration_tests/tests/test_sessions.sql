
with expected as (

    select
        user_custom_id,
        inferred_user_id,
        user_snowplow_domain_id,
        user_snowplow_crossdomain_id,
        app_id,
        first_page_url,
        marketing_medium,
        marketing_source,
        marketing_term,
        marketing_campaign,
        marketing_content,
        referer_url,
        session_start,
        session_end,
        session_id,
        time_engaged_in_s,
        session_index

    from {{ ref('snowplow_sessions_expected') }}

),

actual as (

    select
        user_custom_id,
        inferred_user_id,
        user_snowplow_domain_id,
        user_snowplow_crossdomain_id,
        app_id,
        first_page_url,
        marketing_medium,
        marketing_source,
        marketing_term,
        marketing_campaign,
        marketing_content,
        referer_url,
        session_start,
        session_end,
        session_id,
        time_engaged_in_s,
        session_index

    from {{ ref('snowplow_sessions') }}

),

a_minus_b as (

  select * from expected
  except
  select * from actual

),

b_minus_a as (

  select * from actual
  except
  select * from expected

)

select * from a_minus_b
union all
select * from b_minus_a
