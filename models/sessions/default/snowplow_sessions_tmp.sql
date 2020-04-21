{{
    config(
        materialized='incremental',
        sort='session_start',
        dist='user_snowplow_domain_id',
        unique_key='session_id',
        enabled=is_adapter('default')
    )
}}

with all_web_page_views as (

    select * from {{ ref('snowplow_page_views') }}

),

relevant_sessions as (

    select distinct session_id
    from all_web_page_views

    {% if is_incremental() %}
        where page_view_start > {{get_start_ts(this, 'session_start')}}
    {% endif %}

),

-- only select sessions that had page views in this time frame
-- this strategy helps us grab _all_ of the page views for these
-- sessions, including the ones that occurred before the
-- max(session_start) in the table
web_page_views as (

    select all_web_page_views.*
    from all_web_page_views
    join relevant_sessions using (session_id)

),

prep AS (

    select
        session_id,

        -- time
        min(page_view_start) as session_start,
        max(page_view_end) as session_end,

        min(page_view_start_local) as session_start_local,
        max(page_view_end_local) as session_end_local,

        -- engagement
        count(*) as page_views,

        sum(case when user_engaged then 1 else 0 end) as engaged_page_views,

        sum(time_engaged_in_s) as time_engaged_in_s,

        max(case when last_page_view_in_session = 1 then page_url else null end)
            as exit_page_url
        
        {%- for column in var('snowplow:pass_through_columns') %}
        , max(case when last_page_view_in_session = 1 then {{column}} else null end)
            as {{column}}
        {% endfor %}

    from web_page_views

    group by 1

),

sessions as (

    select
        -- user
        a.user_custom_id,
        a.user_snowplow_domain_id,
        a.user_snowplow_crossdomain_id,

        -- sesssion
        a.session_id,
        a.session_index,

        -- session: time
        b.session_start,
        b.session_end,

        -- session: time in the user's local timezone
        b.session_start_local,
        b.session_end_local,

        -- engagement
        b.page_views,

        b.engaged_page_views,
        b.time_engaged_in_s,

        case
            when b.time_engaged_in_s between 0 and 9 then '0s to 9s'
            when b.time_engaged_in_s between 10 and 29 then '10s to 29s'
            when b.time_engaged_in_s between 30 and 59 then '30s to 59s'
            when b.time_engaged_in_s between 60 and 119 then '60s to 119s'
            when b.time_engaged_in_s between 120 and 239 then '120s to 239s'
            when b.time_engaged_in_s > 239 then '240s or more'
            else null
        end as time_engaged_in_s_tier,

        case when (b.page_views = 1) then true else false end as user_bounced,
        case when (b.page_views > 2 and b.time_engaged_in_s > 59) or b.engaged_page_views > 0 then true else false end as user_engaged,

        -- first page

        a.page_url as first_page_url,

        a.page_url_scheme as first_page_url_scheme,
        a.page_url_host as first_page_url_host,
        a.page_url_port as first_page_url_port,
        a.page_url_path as first_page_url_path,
        a.page_url_query as first_page_url_query,
        a.page_url_fragment as first_page_url_fragment,

        a.page_title as first_page_title,

        -- last page
        b.exit_page_url,

        -- referer
        a.referer_url,

        a.referer_url_scheme,
        a.referer_url_host,
        a.referer_url_port,
        a.referer_url_path,
        a.referer_url_query,
        a.referer_url_fragment,

        a.referer_medium,
        a.referer_source,
        a.referer_term,

        -- marketing
        a.marketing_medium,
        a.marketing_source,
        a.marketing_term,
        a.marketing_content,
        a.marketing_campaign,
        a.marketing_click_id,
        a.marketing_network,

        -- location
        a.geo_country,
        a.geo_region,
        a.geo_region_name,
        a.geo_city,
        a.geo_zipcode,
        a.geo_latitude,
        a.geo_longitude,
        a.geo_timezone, -- can be null

        -- ip
        a.ip_address,
        a.ip_isp,
        a.ip_organization,
        a.ip_domain,
        a.ip_net_speed,

        -- application
        a.app_id,

        -- browser
        a.browser,
        a.browser_name,
        a.browser_major_version,
        a.browser_minor_version,
        a.browser_build_version,
        a.browser_engine,

        a.browser_language,

        -- os
        a.os,
        a.os_name,
        a.os_major_version,
        a.os_minor_version,
        a.os_build_version,
        a.os_manufacturer,
        a.os_timezone,

        -- device
        a.device,
        a.device_type,
        a.device_is_mobile
        
        {%- for column in var('snowplow:pass_through_columns') %}
        , a.{{column}} as first_{{column}}
        , b.{{column}} as last_{{column}}
        {% endfor %}

    from web_page_views as a
        inner join prep as b on a.session_id = b.session_id

    where a.page_view_in_session_index = 1

)

select * from sessions
