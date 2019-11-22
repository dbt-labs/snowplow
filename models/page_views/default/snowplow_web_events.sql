-- transform all *new* events, then delete existing
-- and insert new (by page_view_id). No sql_where because
-- we only want to process _new_ events

{{
    config(
        materialized='incremental',
        sort='page_view_id',
        dist='page_view_id',
        unique_key='page_view_id',
        enabled=is_adapter('default')
    )
}}

with events as (

    select * from ({{ snowplow_web_events_tmp() }})

),

prep as (

    select

        event_id,

        user_id,
        domain_userid,
        network_userid,

        collector_tstamp,

        domain_sessionid,
        domain_sessionidx,

        page_view_id,

        page_title,

        page_urlscheme,
        page_urlhost,
        page_urlport,
        page_urlpath,
        page_urlquery,
        page_urlfragment,

        refr_urlscheme,
        refr_urlhost,
        refr_urlport,
        refr_urlpath,
        refr_urlquery,
        refr_urlfragment,

        refr_medium,
        refr_source,
        refr_term,

        mkt_medium,
        mkt_source,
        mkt_term,
        mkt_content,
        mkt_campaign,
        mkt_clickid,
        mkt_network,

        geo_country,
        geo_region,
        geo_region_name,
        geo_city,
        geo_zipcode,
        geo_latitude,
        geo_longitude,
        geo_timezone,

        user_ipaddress,

        ip_isp,
        ip_organization,
        ip_domain,
        ip_netspeed,

        app_id,

        useragent,
        br_name,
        br_family,
        br_version,
        br_type,
        br_renderengine,
        br_lang,
        dvce_type,
        dvce_ismobile,

        os_name,
        os_family,
        os_manufacturer,
        replace(os_timezone, '%2F', '/') as os_timezone,

        name_tracker, -- included to filter on
        dvce_created_tstamp -- included to sort on
        
        {%- for column in var('snowplow:pass_through_columns') %}
        , {{column}}
        {% endfor %}

    from events

    where platform = 'web'
      and event_name = 'page_view'

),

dedupe as (

    select *,
        row_number () over (partition by page_view_id order by dvce_created_tstamp) as n

    from prep

)

select * from dedupe where n = 1
