{{config(enabled=snowplow.is_adapter('bigquery'))}}

select
    user_custom_id,
    inferred_user_id,
    user_snowplow_domain_id,
    user_snowplow_crossdomain_id,
    app_id,
    landing_page.url as first_page_url,
    marketing.medium as marketing_medium,
    marketing.source as marketing_source,
    marketing.term as marketing_term,
    marketing.campaign as marketing_campaign,
    marketing.content as marketing_content,
    referer.url as referer_url,
    datetime(session_start,'{{var('snowplow:timezone')}}') as session_start,
    datetime(session_end,'{{var('snowplow:timezone')}}') as session_end,
    session_id,
    engagement.time_engaged_in_s,
    session_index,
    first_custom.test_add_col as first_test_add_col,
    last_custom.test_add_col as last_test_add_col

from {{ ref('snowplow_sessions') }}
