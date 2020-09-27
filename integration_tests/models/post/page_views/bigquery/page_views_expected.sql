{{config(enabled=snowplow.is_adapter('bigquery'))}}

select
    nullif(user_custom_id,'NULL') as user_custom_id,
    nullif(user_snowplow_domain_id,'NULL') as user_snowplow_domain_id,
    nullif(user_snowplow_crossdomain_id,'NULL') as user_snowplow_crossdomain_id,
    session_id,
    session_index,
    page_view_id,
    page_view_start,
    page_view_end,
    time_engaged_in_s,
    horizontal_percentage_scrolled,
    vertical_percentage_scrolled,
    nullif(page_url,'NULL') as page_url,
    nullif(marketing_medium,'NULL') as marketing_medium,
    nullif(marketing_source,'NULL') as marketing_source,
    nullif(marketing_term,'NULL') as marketing_term,
    nullif(marketing_content,'NULL') as marketing_content,
    nullif(marketing_campaign,'NULL') as marketing_campaign,
    test_add_col

from {{ ref('snowplow_page_views_expected') }}
