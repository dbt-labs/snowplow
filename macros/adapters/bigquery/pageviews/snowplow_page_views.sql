
{% macro bigquery__snowplow_page_views() %}

{{
    config(
        materialized='incremental',
        partition_by='DATE(page_view_start)',
        unique_key="page_view_id"
    )
}}

{% set timezone = var('snowplow:timezone', 'UTC') %}
{% set start_date = get_most_recent_record(this, "page_view_start", "2001-01-01") %}

/*
    General approach: find sessions that happened since the last time
    the model was processed. The naive approach just grabs events that
    happened on or after this date, but we can miss events that bridge
    midnight. Instead, we fetch an extra day of events, but only consider
    the sessions that occur on or after the start_date. The extra lookback
    day will give us the full picture of events, but we won't reprocess the extra
    events from the previous day unless they are present on the `start_date`.
*/

with all_events as (

    select *
    from {{ ref('snowplow_base_events') }}

    -- load up events from the start date, and the day before it, to ensure
    -- that we capture pageviews that span midnight
    where DATE(collector_tstamp) >= date_sub('{{ start_date }}', interval 1 day)

),

new_sessions as (

    select distinct
        domain_sessionid

    from all_events

    -- only consider events for sessions that occurred on or after the start_date
    where DATE(collector_tstamp) >= '{{ start_date }}'

),

relevant_events as (

    select *,
        row_number() over (partition by event_id order by dvce_created_tstamp) as dedupe

    from all_events
    where domain_sessionid in (select distinct domain_sessionid from new_sessions)

),

web_page_context as (

    select root_id as event_id, page_view_id from {{ ref('snowplow_web_page_context') }}

),

events as (

    select
        web_page_context.page_view_id,
        relevant_events.* except (dedupe)

    from relevant_events
    join web_page_context using (event_id)
    where dedupe = 1

),

page_views as (

  select
    user_id as user_custom_id,
    domain_userid as user_snowplow_domain_id,
    network_userid as user_snowplow_crossdomain_id,
    app_id,

    domain_sessionid as session_id,
    domain_sessionidx as session_index,

    page_view_id,

    row_number() over (partition by domain_userid order by dvce_created_tstamp) as page_view_index,
    row_number() over (partition by domain_sessionid order by dvce_created_tstamp) as page_view_in_session_index,
    count(*) over (partition by domain_sessionid) as max_session_page_view_index,

    struct(
      concat(page_urlhost, page_urlpath) as url,
      page_urlscheme as scheme,
      page_urlhost as host,
      page_urlport as port,
      page_urlpath as path,
      page_urlquery as query,
      page_urlfragment as fragment,
      page_title as title,
      page_url as full_url
    ) as page,

    struct(
      concat(refr_urlhost, refr_urlpath) as url,
      refr_urlscheme as scheme,
      refr_urlhost as host,
      refr_urlport as port,
      refr_urlpath as path,
      refr_urlquery as query,
      refr_urlfragment as fragment,

      case
        when refr_medium is null then 'direct'
        when refr_medium = 'unknown' then 'other'
        else refr_medium
      end as medium,
      refr_source as source,
      refr_term as term
    ) as referer,

    struct(
      mkt_medium as medium,
      mkt_source as source,
      mkt_term as term,
      mkt_content as content,
      mkt_campaign as campaign,
      mkt_clickid as click_id,
      mkt_network as network
    ) as marketing,

    struct(
      user_ipaddress as ip_address,
      ip_isp as isp,
      ip_organization as organization,
      ip_domain as domain,
      ip_netspeed as net_speed
    ) as ip,

    struct(
      geo_city as city,
      geo_country as country,
      geo_latitude as latitude,
      geo_longitude as longitude,
      geo_region as region,
      geo_region_name as region_name,
      geo_timezone as timezone,
      geo_zipcode as zipcode
    ) as geo,

    struct(
      os_family as family,
      os_manufacturer as manufacturer,
      os_name as name,
      os_timezone as timezone
    ) as os,

    br_lang as browser_language,

    -- TODO : useragent
    -- TODO : perf_timing

    struct(
        br_renderengine as browser_engine,
        dvce_type as type,
        dvce_ismobile as is_mobile
    ) as device

  from events
  where event = 'page_view'
    and (br_family != 'Robot/Spider' or br_family is null)
    and (
        not regexp_contains(useragent, '^.*(bot|crawl|slurp|spider|archiv|spinn|sniff|seo|audit|survey|pingdom|worm|capture|(browser|screen)shots|analyz|index|thumb|check|facebook|PingdomBot|PhantomJS|YandexBot|Twitterbot|a_archiver|facebookexternalhit|Bingbot|BingPreview|Googlebot|Baiduspider|360(Spider|User-agent)|semalt).*$')
        or useragent is null
    )
    and domain_userid is not null
    and domain_sessionidx > 0

),

page_pings as (

  select
    page_view_id,
    min(timestamp(collector_tstamp)) as page_view_start,
    max(timestamp(collector_tstamp)) as page_view_end,

    struct(
        max(doc_width) as doc_width,
        max(doc_height) as doc_height,
        max(br_viewwidth) as view_width,
        max(br_viewheight) as view_height
    ) as browser,

    least(greatest(min(coalesce(pp_xoffset_min, 0)), 0), max(doc_width)) as hmin,
    least(greatest(max(coalesce(pp_xoffset_max, 0)), 0), max(doc_width)) as hmax,
    least(greatest(min(coalesce(pp_yoffset_min, 0)), 0), max(doc_height)) as vmin,
    least(greatest(max(coalesce(pp_yoffset_max, 0)), 0), max(doc_height)) as vmax,

    sum(case when event = 'page_view' then 1 else 0 end) as pv_count,
    sum(case when event = 'page_ping' then 1 else 0 end) as pp_count,
    sum(case when event = 'page_ping' then 1 else 0 end) * {{ var('snowplow:page_ping_frequency', 30) }} as time_engaged_in_s,

    array_agg(struct(
      event_id,
      event,
      timestamp(collector_tstamp) as collector_tstamp,
      pp_xoffset_min,
      pp_xoffset_max,
      pp_yoffset_min,
      pp_yoffset_max,
      doc_width,
      doc_height
    ) order by collector_tstamp) as page_pings

  from events
  where event in ('page_ping', 'page_view')
  group by 1

),

page_pings_xf as (

    select
      *,
      round(100*(greatest(hmin, 0)/nullif(browser.doc_width, 0))) as x_scroll_pct_min,
      round(100*(least(hmax + browser.view_width, browser.doc_width)/nullif(browser.doc_width, 0))) as x_scroll_pct,
      round(100*(greatest(vmin, 0)/nullif(browser.doc_height, 0))) as y_scroll_pct_min,
      round(100*(least(vmax + browser.view_height, browser.doc_height)/nullif(browser.doc_height, 0))) as y_scroll_pct

    from page_pings

),

engagement as (

  select
    page_view_id,

    page_view_start,
    page_view_end,

    browser,

    struct(
      x_scroll_pct,
      y_scroll_pct,
      x_scroll_pct_min,
      y_scroll_pct_min,
      time_engaged_in_s,
      case
            when time_engaged_in_s between 0 and 9 then '0s to 9s'
            when time_engaged_in_s between 10 and 29 then '10s to 29s'
            when time_engaged_in_s between 30 and 59 then '30s to 59s'
            when time_engaged_in_s > 59 then '60s or more'
            else null
      end as time_engaged_in_s_tier,
      case when time_engaged_in_s >= 30 and y_scroll_pct >= 25 then true else false end as engaged
    ) as engagement

  from page_pings_xf

)

select *
from page_views
join engagement using (page_view_id)

{% endmacro %}
