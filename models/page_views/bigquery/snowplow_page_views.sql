{{
    config(
        materialized='incremental',
        partition_by={
            'field': 'page_view_start',
            'data_type': 'timestamp'
        },
        unique_key='page_view_id',
        cluster_by='page_view_id',
        enabled=is_adapter('bigquery')
    )
}}

{% set timezone = var('snowplow:timezone', 'UTC') %}

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

    {% if is_incremental() %}
        
        where date(collector_tstamp) >= 
            date_sub(
                {{get_start_ts(this)}},
                interval {{var('snowplow:page_view_lookback_days')}} day
            )
    
    {% endif %}

),

relevant_events as (

    select *,
        row_number() over (partition by event_id order by dvce_created_tstamp) as dedupe

    from all_events
    where domain_sessionid is not null

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

{% if use_perf_timing != false %}

    web_timing_context as ( select * from {{ ref('snowplow_web_timing_context') }} ),

{% endif %}

{% if use_useragents != false %}

    web_ua_parser_context as ( select * from {{ ref('snowplow_web_ua_parser_context') }} ),

{% endif %}

page_views as (

  select
    -- user
    e.user_id as user_custom_id,
    e.domain_userid as user_snowplow_domain_id,
    e.network_userid as user_snowplow_crossdomain_id,

    -- session
    e.domain_sessionid as session_id,
    e.domain_sessionidx as session_index,

    -- page view
    e.page_view_id,

    row_number() over (partition by e.domain_userid order by e.dvce_created_tstamp) as page_view_index,
    row_number() over (partition by e.domain_sessionid order by e.dvce_created_tstamp) as page_view_in_session_index,
    count(*) over (partition by e.domain_sessionid) as max_session_page_view_index,

    -- page
    struct(
      concat(e.page_urlhost, e.page_urlpath) as url,
      e.page_urlscheme as url_scheme,
      e.page_urlhost as url_host,
      e.page_urlport as url_port,
      e.page_urlpath as url_path,
      e.page_urlquery as url_query,
      e.page_urlfragment as url_fragment,
      e.page_title as title
    ) as page,

    -- referer
    struct(
      case
        when e.refr_medium is null then 'direct'
        when e.refr_medium = 'unknown' then 'other'
        else e.refr_medium
      end as medium,
      e.refr_source as source,
      e.refr_term as term,

      concat(e.refr_urlhost, e.refr_urlpath) as url,
      e.refr_urlscheme as url_scheme,
      e.refr_urlhost as url_host,
      e.refr_urlport as url_port,
      e.refr_urlpath as url_path,
      e.refr_urlquery as url_query,
      e.refr_urlfragment as url_fragment
    ) as referer,

    -- marketing
    struct(
      e.mkt_medium as medium,
      e.mkt_source as source,
      e.mkt_term as term,
      e.mkt_content as content,
      e.mkt_campaign as campaign,
      e.mkt_clickid as click_id,
      e.mkt_network as network
    ) as marketing,

    -- location
    struct(
      e.geo_country as country,
      e.geo_region as region,
      e.geo_region_name as region_name,
      e.geo_city as city,
      e.geo_zipcode as zipcode,
      e.geo_latitude as latitude,
      e.geo_longitude as longitude,
      e.geo_timezone as timezone
    ) as geo,

    -- ip
    struct(
      e.user_ipaddress as address,
      e.ip_isp as isp,
      e.ip_organization as organization,
      e.ip_domain as domain,
      e.ip_netspeed as net_speed
    ) as ip,

    -- application
    e.app_id,

    -- browser
    struct(
      e.br_lang as language,
      e.br_renderengine as engine,
      {% if use_useragents %}
          d.useragent_version as version,
          d.useragent_family as name,
          d.useragent_major as major_version,
          d.useragent_minor as minor_version,
          d.useragent_patch as build_version
      {% else %}
          cast(null as {{ dbt.type_string() }}) as version,
          e.br_family as name,
          e.br_name as major_version,
          e.br_version as minor_version,
          cast(null as {{ dbt.type_string() }}) as build_version
      {% endif %}
    ) as browser,

    -- os
    struct(
      e.os_manufacturer as manufacturer,
      e.os_timezone as timezone,
      {% if use_useragents %}
            d.os_version as version,
            d.os_family as name,
            d.os_major as major_version,
            d.os_minor as minor_version,
            d.os_patch as build_version
        {% else %}
            e.os_family as version,
            e.os_name as name,
            cast(null as {{ dbt.type_string() }}) as major_version,
            cast(null as {{ dbt.type_string() }}) as minor_version,
            cast(null as {{ dbt.type_string() }}) as build_version
        {% endif %}
    ) as os,

    struct(
      {% if use_perf_timing %}
            t.redirect_time_in_ms,
            t.unload_time_in_ms,
            t.app_cache_time_in_ms,
            t.dns_time_in_ms,
            t.tcp_time_in_ms,
            t.request_time_in_ms,
            t.response_time_in_ms,
            t.processing_time_in_ms,
            t.dom_loading_to_interactive_time_in_ms,
            t.dom_interactive_to_complete_time_in_ms,
            t.onload_time_in_ms,
            t.total_time_in_ms
      {% else %}
            cast(null as bigint) as redirect_time_in_ms,
            cast(null as bigint) as unload_time_in_ms,
            cast(null as bigint) as app_cache_time_in_ms,
            cast(null as bigint) as dns_time_in_ms,
            cast(null as bigint) as tcp_time_in_ms,
            cast(null as bigint) as request_time_in_ms,
            cast(null as bigint) as response_time_in_ms,
            cast(null as bigint) as processing_time_in_ms,
            cast(null as bigint) as dom_loading_to_interactive_time_in_ms,
            cast(null as bigint) as dom_interactive_to_complete_time_in_ms,
            cast(null as bigint) as onload_time_in_ms,
            cast(null as bigint) as total_time_in_ms
      {% endif %}
    ) as performance_timing,

    -- device
    struct(
        e.dvce_type as type,
        e.dvce_ismobile as is_mobile,
        {% if use_useragents %}
            d.device_family as family
        {% else %}
            cast(null as {{ dbt.type_string() }}) as family
        {% endif %}
    ) as device

    -- custom columns
    {%- if var('snowplow:pass_through_columns') | length > 0 %}
    , struct(
        {{ var('snowplow:pass_through_columns') | join(',\n') }}
    ) as custom
    {% endif %}

  from events as e
    {% if use_useragents %}

        left outer join web_ua_parser_context as d on e.page_view_id = d.page_view_id

    {% endif %}

    {% if use_perf_timing %}

          left outer join web_timing_context as t on e.page_view_id = t.page_view_id

    {% endif %}

  where e.event = 'page_view'
    and (e.br_family != 'Robot/Spider' or e.br_family is null)
    and (
        {% set bad_agents_psv = bot_any()|join('|') %}
        not regexp_contains(LOWER(e.useragent), '^.*({{bad_agents_psv}}).*$')
        or useragent is null
    )
    and e.domain_userid is not null
    and e.domain_sessionidx > 0

),

page_pings as (

  select
    page_view_id,
    min(cast(collector_tstamp as timestamp)) as page_view_start,
    max(cast(collector_tstamp as timestamp)) as page_view_end,

    struct(
        max(doc_width) as doc_width,
        max(doc_height) as doc_height,
        max(br_viewwidth) as view_width,
        max(br_viewheight) as view_height
    ) as window_size,

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
      cast(collector_tstamp as timestamp) as collector_tstamp,
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
      round(100*(greatest(hmin, 0)/nullif(window_size.doc_width, 0))) as x_scroll_pct_min,
      round(100*(least(hmax + window_size.view_width, window_size.doc_width)/nullif(window_size.doc_width, 0))) as x_scroll_pct,
      round(100*(greatest(vmin, 0)/nullif(window_size.doc_height, 0))) as y_scroll_pct_min,
      round(100*(least(vmax + window_size.view_height, window_size.doc_height)/nullif(window_size.doc_height, 0))) as y_scroll_pct

    from page_pings

),

engagement as (

  select
    page_view_id,

    page_view_start,
    page_view_end,

    window_size,

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
