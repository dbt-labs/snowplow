
{% macro snowplow_web_events() %}

    {{ adapter_macro('snowplow.snowplow_web_events') }}

{% endmacro %}


{% macro default__snowplow_web_events() %}

-- transform all *new* events, then delete existing
-- and insert new (by page_view_id). No sql_where because
-- we only want to process _new_ events

{{
    config(
        materialized='incremental',
        sort='page_view_id',
        dist='page_view_id',
        sql_where='TRUE',
        unique_key='page_view_id'
    )
}}


with all_events as (

    select * from {{ ref('snowplow_base_events') }}

),

events as (

    select * from all_events
    {% if adapter.already_exists(this.schema, this.name) and not flags.FULL_REFRESH %}
    where collector_tstamp > (
        select coalesce(max(collector_tstamp), '0001-01-01') from {{ this }}
    )
    {% endif %}

),

web_page_context as (

    select * from {{ ref('snowplow_web_page_context') }}

),

prep as (

    select

        ev.event_id,

        ev.user_id,
        ev.domain_userid,
        ev.network_userid,

        ev.collector_tstamp,

        ev.domain_sessionid,
        ev.domain_sessionidx,

        wp.page_view_id,

        ev.page_title,

        ev.page_urlscheme,
        ev.page_urlhost,
        ev.page_urlport,
        ev.page_urlpath,
        ev.page_urlquery,
        ev.page_urlfragment,

        ev.refr_urlscheme,
        ev.refr_urlhost,
        ev.refr_urlport,
        ev.refr_urlpath,
        ev.refr_urlquery,
        ev.refr_urlfragment,

        ev.refr_medium,
        ev.refr_source,
        ev.refr_term,

        ev.mkt_medium,
        ev.mkt_source,
        ev.mkt_term,
        ev.mkt_content,
        ev.mkt_campaign,
        ev.mkt_clickid,
        ev.mkt_network,

        ev.geo_country,
        ev.geo_region,
        ev.geo_region_name,
        ev.geo_city,
        ev.geo_zipcode,
        ev.geo_latitude,
        ev.geo_longitude,
        ev.geo_timezone,

        ev.user_ipaddress,

        ev.ip_isp,
        ev.ip_organization,
        ev.ip_domain,
        ev.ip_netspeed,

        ev.app_id,

        ev.useragent,
        ev.br_name,
        ev.br_family,
        ev.br_version,
        ev.br_type,
        ev.br_renderengine,
        ev.br_lang,
        ev.dvce_type,
        ev.dvce_ismobile,

        ev.os_name,
        ev.os_family,
        ev.os_manufacturer,
        ev.os_timezone,

        ev.name_tracker, -- included to filter on
        ev.dvce_created_tstamp -- included to sort on

    from events as ev
        inner join web_page_context as wp  on ev.event_id = wp.root_id

    where ev.platform = 'web'
      and ev.event_name = 'page_view'

),

dedupe as (

    select *,
        row_number () over (partition by page_view_id order by dvce_created_tstamp) as n

    from prep

)

select * from dedupe where n = 1

{% endmacro %}
