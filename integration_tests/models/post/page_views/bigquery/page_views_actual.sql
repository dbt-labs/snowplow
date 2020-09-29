{{config(enabled=snowplow.is_adapter('bigquery'))}}

select
    user_custom_id,
    user_snowplow_domain_id,
    user_snowplow_crossdomain_id,
    session_id,
    session_index,
    page_view_id,
    datetime(page_view_start,'{{var('snowplow:timezone')}}') as page_view_start,
    datetime(page_view_end,'{{var('snowplow:timezone')}}') as page_view_end,
    engagement.time_engaged_in_s,
    engagement.x_scroll_pct as horizontal_percentage_scrolled,
    engagement.y_scroll_pct as vertical_percentage_scrolled,
    page.url as page_url,
    marketing.medium as marketing_medium,
    marketing.source as marketing_source,
    marketing.term as marketing_term,
    marketing.content as marketing_content,
    marketing.campaign as marketing_campaign,
    custom.test_add_col

from {{ ref('snowplow_page_views') }}
