{{
    config(
        materialized='incremental',
        partition_by={
            'field': 'session_start',
            'data_type': 'timestamp'
        },
        unique_key='session_id',
        cluster_by='session_id',
        enabled=is_adapter('bigquery')
    )
}}

with all_page_views as (

    select * from {{ ref('snowplow_page_views') }}
    
    {% if is_incremental() %}
        where date(page_view_start) >= {{get_start_ts(this)}}
    {% endif %}

),

new_page_views as (

    select distinct
        session_id

    from all_page_views

),

relevant_page_views as (

    select *
    from all_page_views
    where session_id in (select distinct session_id from new_page_views)

),

sessions_agg as (

    select
        pv.session_id,
        array_agg(pv order by pv.page_view_in_session_index) as all_pageviews

    from relevant_page_views as pv
    group by 1

),

sessions_agg_xf as (

    select
        session_id,
        all_pageviews,
        all_pageviews[safe_offset(0)] as first_page_view,
        all_pageviews[safe_offset(array_length(all_pageviews) - 1)] as exit_page_view,

        (
            select struct(
                (count(*) = 1) as user_bounced,
                sum(case when engagement.engaged then 1 else 0 end) as engaged_page_views,
                sum(engagement.time_engaged_in_s) as time_engaged_in_s
            )
            from unnest(all_pageviews)
        ) as engagement,

        (
            select struct(
                min(page_view_start) as session_start,
                max(page_view_end) as session_end
            )
            from unnest(all_pageviews)
        ) as timing


    from sessions_agg

),

sessions as (

  select
    first_page_view.user_custom_id,
    first_page_view.user_snowplow_domain_id,
    first_page_view.user_snowplow_crossdomain_id,

    first_page_view.session_id,
    first_page_view.session_index,

    first_page_view.app_id,

    timing.session_start,
    timing.session_end,
    array_length(all_pageviews) as count_page_views,

    struct(
        engagement.engaged_page_views,
        engagement.user_bounced,
        engagement.time_engaged_in_s,
        case
            when engagement.time_engaged_in_s between 0 and 9 then '0s to 9s'
            when engagement.time_engaged_in_s between 10 and 29 then '10s to 29s'
            when engagement.time_engaged_in_s between 30 and 59 then '30s to 59s'
            when engagement.time_engaged_in_s between 60 and 119 then '60s to 119s'
            when engagement.time_engaged_in_s between 120 and 239 then '120s to 239s'
            when engagement.time_engaged_in_s > 239 then '240s or more'
            else null
        end as time_engaged_in_s_tier
    ) as engagement,

    first_page_view.page as landing_page,
    exit_page_view.page as exit_page,

    first_page_view.referer as referer,
    first_page_view.marketing as marketing,
    first_page_view.geo as geo,
    first_page_view.ip as ip,
    first_page_view.browser as browser,
    first_page_view.os as os,
    first_page_view.device as device,
    
    {% if var('snowplow:pass_through_columns') | length > 0 %}
    first_page_view.custom as first_custom,
    exit_page_view.custom as last_custom,
    {% endif %}

    array(
      select struct(
        page_view_id,
        page_view_start,
        page_view_end,
        page,
        engagement
     )
     from unnest(all_pageviews) order by page_view_start
   ) as page_views

  from sessions_agg_xf

)

select *
from sessions
