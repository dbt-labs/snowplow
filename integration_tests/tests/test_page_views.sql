
with expected as (

    select
        user_custom_id,
        user_snowplow_domain_id,
        user_snowplow_crossdomain_id,
        session_id,
        session_index,
        page_view_id,
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
        marketing_campaign

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
        marketing_campaign

    from {{ ref('snowplow_page_views') }}

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


