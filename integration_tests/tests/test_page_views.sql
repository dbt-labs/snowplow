
with expected as (

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

),

actual as (

    select
        user_custom_id,
        user_snowplow_domain_id,
        user_snowplow_crossdomain_id,
        session_id,
        session_index,
        page_view_id,
        {% if target.type == 'bigquery' -%}
        datetime(page_view_start,'{{var('snowplow:timezone')}}') as page_view_start,
        datetime(page_view_end,'{{var('snowplow:timezone')}}') as page_view_end,
        engagement.time_engaged_in_s,
        engagement.x_scroll_pct,
        engagement.y_scroll_pct,
        page.url,
        marketing.medium,
        marketing.source,
        marketing.term,
        marketing.content,
        marketing.campaign,
        custom.test_add_col
        {%- else -%}
        page_view_start,
        page_view_end,
        time_engaged_in_s,
        horizontal_percentage_scrolled,
        vertical_percentage_scrolled,
        page_url,
        marketing_medium,
        marketing_source,
        marketing_term,
        marketing_content,
        marketing_campaign,
        test_add_col
        {%- endif %}

    from {{ ref('snowplow_page_views') }}

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


