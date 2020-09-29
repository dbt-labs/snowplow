{{config(enabled=snowplow.is_adapter('bigquery'))}}

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
    session_index,
    first_test_add_col,
    last_test_add_col

from {{ ref('snowplow_sessions_expected') }}
