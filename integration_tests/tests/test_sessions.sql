
with expected as (

    select
        nullif(user_custom_id,'NULL') as user_custom_id,
        nullif(inferred_user_id,'NULL') as inferred_user_id,
        nullif(user_snowplow_domain_id,'NULL') as user_snowplow_domain_id,
        nullif(user_snowplow_crossdomain_id,'NULL') as user_snowplow_crossdomain_id,
        nullif(app_id,'NULL') as app_id,
        nullif(first_page_url,'NULL') as first_page_url,
        nullif(marketing_medium,'NULL') as marketing_medium,
        nullif(marketing_source,'NULL') as marketing_source,
        nullif(marketing_term,'NULL') as marketing_term,
        nullif(marketing_campaign,'NULL') as marketing_campaign,
        nullif(marketing_content,'NULL') as marketing_content,
        nullif(referer_url,'NULL') as referer_url,
        session_start,
        session_end,
        nullif(session_id,'NULL') as session_id,
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
        {% if target.type == 'bigquery' -%}
        landing_page.url,
        marketing.medium,
        marketing.source,
        marketing.term,
        marketing.campaign,
        marketing.content,
        referer.url,
        datetime(session_start,'{{var('snowplow:timezone')}}') as session_start,
        datetime(session_end,'{{var('snowplow:timezone')}}') as session_end,
        session_id,
        engagement.time_engaged_in_s,
        {%- else -%}
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
        {%- endif -%}
        session_index

    from {{ ref('snowplow_sessions') }}

),

a_minus_b as (

  select * from expected
  {{ dbt_utils.except() }}
  select * from actual

),

b_minus_a as (

  select * from actual
  {{ dbt_utils.except() }}
  select * from expected

)

select * from a_minus_b
union all
select * from b_minus_a
