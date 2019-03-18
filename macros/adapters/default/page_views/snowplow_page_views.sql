
{% macro snowplow_page_views() %}

    {{ adapter_macro('snowplow.snowplow_page_views') }}

{% endmacro %}


{% macro default__snowplow_page_views() %}

{{
    config(
        materialized='incremental',
        sort='max_tstamp',
        dist='user_snowplow_domain_id',
        unique_key='page_view_id'
    )
}}


-- initializations
{% set timezone = var('snowplow:timezone', 'UTC') %}

{% set use_perf_timing = (var('snowplow:context:performance_timing') != false) %}
{% set use_useragents = (var('snowplow:context:useragent') != false) %}

with all_events as (

    select * from {{ ref('snowplow_web_events') }}
),

filtered_events as (

    select * from all_events
    {% if is_incremental() %}
    where collector_tstamp > (
        select coalesce(max(max_tstamp), '0001-01-01') from {{ this }}
    )
    {% endif %}

),

-- we need to grab all events for any session that has appeared
-- in order to correctly process the session index below
relevant_sessions as (

    select distinct domain_sessionid
    from filtered_events
),

web_events as (

    select all_events.*
    from all_events
    join relevant_sessions using (domain_sessionid)

),

internal_session_mapping as (

    select * from {{ ref('snowplow_web_events_internal_fixed') }}

),

-- coalesce "stagnant" sessions which would result in internal referers
web_events_fixed as (

    select
        -- use parent if available, otherwise use session id on web event
        coalesce(i.parent_sessionid, w.domain_sessionid) as session_id,

        -- use web params if they're there, otherwise fall back to parent
        -- the i.utm_* fields are only defined if the current web event is internal,
        -- so this doesn't play with "correct" sessions -- only the orphaned ones
        coalesce(w.mkt_medium, i.utm_medium) as marketing_medium,
        coalesce(w.mkt_source, i.utm_source) as marketing_source,
        coalesce(w.mkt_campaign, i.utm_campaign) as marketing_campaign,
        coalesce(w.mkt_term, i.utm_term) as marketing_term,
        coalesce(w.mkt_content, i.utm_content) as marketing_content,

        -- likewise, replace the urlquery with parent's if internal & undefined in this pv
        coalesce(w.page_urlquery, i.parent_urlquery) as page_url_query,

        w.*

    from web_events as w
    left outer join internal_session_mapping as i on i.domain_sessionid = w.domain_sessionid

),

web_events_time as (

    select * from {{ ref('snowplow_web_events_time') }}

),

web_events_scroll_depth as (

    select * from {{ ref('snowplow_web_events_scroll_depth') }}

),

{% if use_perf_timing != false %}

    web_timing_context as ( select * from {{ ref('snowplow_web_timing_context') }} ),

{% endif %}

{% if use_useragents != false %}

    web_ua_parser_context as ( select * from {{ ref('snowplow_web_ua_parser_context') }} ),

{% endif %}

prep as (

    select
        -- user
        a.user_id as user_custom_id,
        a.domain_userid as user_snowplow_domain_id,
        a.network_userid as user_snowplow_crossdomain_id,

        b.min_tstamp,
        b.max_tstamp,

        -- sesssion
        a.session_id,
        a.domain_sessionidx as session_index,

        -- page view
        a.page_view_id,

        row_number() over (partition by a.domain_userid order by a.dvce_created_tstamp) as page_view_index,
        row_number() over (partition by a.session_id order by a.dvce_created_tstamp) as page_view_in_session_index,
        count(*) over (partition by session_id) as max_session_page_view_index,

        -- page view: time
        CONVERT_TIMEZONE('UTC', '{{ timezone }}', b.min_tstamp) as page_view_start,
        CONVERT_TIMEZONE('UTC', '{{ timezone }}', b.max_tstamp) as page_view_end,

        -- page view: time in the user's local timezone
        convert_timezone('UTC', coalesce(a.os_timezone, '{{ timezone }}'), b.min_tstamp) as page_view_start_local,
        convert_timezone('UTC', coalesce(a.os_timezone, '{{ timezone }}'), b.max_tstamp) as page_view_end_local,

        -- engagement
        b.time_engaged_in_s,

        case
            when b.time_engaged_in_s between 0 and 9 then '0s to 9s'
            when b.time_engaged_in_s between 10 and 29 then '10s to 29s'
            when b.time_engaged_in_s between 30 and 59 then '30s to 59s'
            when b.time_engaged_in_s > 59 then '60s or more'
            else null
        end as time_engaged_in_s_tier,

        c.hmax as horizontal_pixels_scrolled,
        c.vmax as vertical_pixels_scrolled,

        c.relative_hmax as horizontal_percentage_scrolled,
        c.relative_vmax as vertical_percentage_scrolled,

        case
            when c.relative_vmax between 0 and 24 then '0% to 24%'
            when c.relative_vmax between 25 and 49 then '25% to 49%'
            when c.relative_vmax between 50 and 74 then '50% to 74%'
            when c.relative_vmax between 75 and 100 then '75% to 100%'
            else null
        end as vertical_percentage_scrolled_tier,

        case when b.time_engaged_in_s >= 30 and c.relative_vmax >= 25 then true else false end as user_engaged,

        -- page
        a.page_urlhost || a.page_urlpath as page_url,

        a.page_urlscheme as page_url_scheme,
        a.page_urlhost as page_url_host,
        a.page_urlport as page_url_port,
        a.page_urlpath as page_url_path,
        a.page_url_query,
        a.page_urlfragment as page_url_fragment,

        a.page_title,

        c.doc_width as page_width,
        c.doc_height as page_height,

        -- referer
        a.refr_urlhost || a.refr_urlpath as referer_url,

        a.refr_urlscheme as referer_url_scheme,
        a.refr_urlhost as referer_url_host,
        a.refr_urlport as referer_url_port,
        a.refr_urlpath as referer_url_path,
        a.refr_urlquery as referer_url_query,
        a.refr_urlfragment as referer_url_fragment,

        case
        when a.refr_medium is null then 'direct'
        when a.refr_medium = 'unknown' then 'other'
        else a.refr_medium
        end as referer_medium,
        a.refr_source as referer_source,
        a.refr_term as referer_term,

        -- marketing
        -- these are "fixed" in the CTE above (if needed)
        a.marketing_medium,
        a.marketing_source,
        a.marketing_term,
        a.marketing_content,
        a.marketing_campaign,
        -- these come straight from the event
        a.mkt_clickid as marketing_click_id,
        a.mkt_network as marketing_network,

        -- location
        a.geo_country,
        a.geo_region,
        a.geo_region_name,
        a.geo_city,
        a.geo_zipcode,
        a.geo_latitude,
        a.geo_longitude,
        a.geo_timezone, -- often null (use os_timezone instead)

        -- ip
        a.user_ipaddress as ip_address,
        a.ip_isp,
        a.ip_organization,
        a.ip_domain,
        a.ip_netspeed as ip_net_speed,

        -- application
        a.app_id,

        {% if use_useragents %}
            d.useragent_version as browser,
            d.useragent_family as browser_name,
            d.useragent_major as browser_major_version,
            d.useragent_minor as browser_minor_version,
            d.useragent_patch as browser_build_version,
            d.os_version as os,
            d.os_family as os_name,
            d.os_major as os_major_version,
            d.os_minor as os_minor_version,
            d.os_patch as os_build_version,
            d.device_family as device,
        {% else %}
            null::text as browser,
            null::text as browser_name,
            null::text as browser_major_version,
            null::text as browser_minor_version,
            null::text as browser_build_version,
            a.os_family as os,
            a.os_name as os_name,
            null::text as os_major_version,
            null::text as os_minor_version,
            null::text as os_build_version,
            null::text as device,
        {% endif %}

        c.br_viewwidth as browser_window_width,
        c.br_viewheight as browser_window_height,

        a.br_lang as browser_language,

        -- os
        a.os_manufacturer,
        a.os_timezone,

        {% if use_perf_timing %}
            e.redirect_time_in_ms,
            e.unload_time_in_ms,
            e.app_cache_time_in_ms,
            e.dns_time_in_ms,
            e.tcp_time_in_ms,
            e.request_time_in_ms,
            e.response_time_in_ms,
            e.processing_time_in_ms,
            e.dom_loading_to_interactive_time_in_ms,
            e.dom_interactive_to_complete_time_in_ms,
            e.onload_time_in_ms,
            e.total_time_in_ms,
        {% else %}
            null::integer as redirect_time_in_ms,
            null::integer as unload_time_in_ms,
            null::integer as app_cache_time_in_ms,
            null::integer as dns_time_in_ms,
            null::integer as tcp_time_in_ms,
            null::integer as request_time_in_ms,
            null::integer as response_time_in_ms,
            null::integer as processing_time_in_ms,
            null::integer as dom_loading_to_interactive_time_in_ms,
            null::integer as dom_interactive_to_complete_time_in_ms,
            null::integer as onload_time_in_ms,
            null::integer as total_time_in_ms,
        {% endif %}

        -- device
        a.br_renderengine as browser_engine,
        a.dvce_type as device_type,
        a.dvce_ismobile as device_is_mobile


    from web_events_fixed as a
        inner join web_events_time as b on a.page_view_id = b.page_view_id
        inner join web_events_scroll_depth as c on a.page_view_id = c.page_view_id

        {% if use_useragents %}

            left outer join web_ua_parser_context as d on a.page_view_id = d.page_view_id

        {% endif %}

        {% if use_perf_timing %}

            left outer join web_timing_context as e on a.page_view_id = e.page_view_id

        {% endif %}

    where (a.br_family != 'Robot/Spider' or a.br_family is null)
      and (
        a.useragent not {{ snowplow.similar_to('%(bot|crawl|slurp|spider|archiv|spinn|sniff|seo|audit|survey|pingdom|worm|capture|(browser|screen)shots|analyz|index|thumb|check|facebook|PingdomBot|PhantomJS|YandexBot|Twitterbot|a_archiver|facebookexternalhit|Bingbot|BingPreview|Googlebot|Baiduspider|360(Spider|User-agent)|semalt)%') }}
        or a.useragent is null
      )
      and a.domain_userid is not null
      and a.domain_sessionidx > 0

),


final as (

    select
        *,
        case
            when max_session_page_view_index = page_view_in_session_index
                then 1
            else 0
        end as last_page_view_in_session
    from prep
)

select * from final

{% endmacro %}
