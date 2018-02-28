{% set br_viewwidth = "
    case
        when br_viewheight like '%x%'
        then split_part(br_viewheight, 'x', 1)::integer
        else null
    end
"%}

{% set br_viewheight = "
    case
        when br_viewheight like '%x%'
        then split_part(br_viewheight, 'x', 2)::integer
        else null
    end
"%}


with fivetran_events as (

    select * from {{ var('snowplow:events') }}

),

fixed as (

    select *,
        -- Fivetran doesn't exactly adhere to the Snowplow spec.
        -- Just make these fields null so we can use the open source snowplow dbt package
        collector_tstamp as derived_tstamp,
        dvce_tstamp::timestamp as dvce_created_tstamp,
        case when event = 'pv' then 'page_view'
             when event = 'pp' then 'page_ping'
        else event end as fixed_event,
        null::timestamp as etl_tstamp,
        null as dvce_screenwidth,
        null as mkt_clickid,
        null as mkt_network

    from fivetran_events

    where
        -- this breaks the snowplow package
        (br_viewheight is null or br_viewheight != 'cliqz.com/tracking')

), renamed as (

    select
        br_name,
        br_family,
        br_version,
        br_type,
        br_renderengine,
        collector_tstamp,
        dvce_type,
        dvce_ismobile,
        os_name,
        os_family,
        os_manufacturer,
        event_vendor,
        event_format,
        event_version,
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
        refr_urlfragment,
        refr_medium,
        refr_source,
        refr_term,
        nullif(mkt_source, '') as mkt_source,
        nullif(mkt_medium, '') as mkt_medium,
        nullif(mkt_campaign, '') as mkt_campaign,
        nullif(mkt_term, '') as mkt_term,
        nullif(mkt_content, '') as mkt_content,
        sequence_number,
        fixed_event as event, -- *
        fixed_event as event_name, -- *
        user_ipaddress,
        app_id,
        platform,
        txn_id,
        user_id,
        domain_userid,
        network_userid,
        user_fingerprint,
        domain_sessionidx,
        domain_sessionid,
        dvce_sent_tstamp,
        name_tracker,
        v_tracker,
        v_collector,
        br_lang,
        br_features_pdf,
        br_features_flash,
        br_features_java,
        br_features_director,
        br_features_quicktime,
        br_features_realplayer,
        br_features_windowsmedia,
        br_features_gears,
        br_features_silverlight,
        br_cookies,
        dvce_screenheight,
        br_colordepth,
        os_timezone,
        page_url,
        doc_charset,
        doc_height,
        doc_width,
        event_id,
        se_category,
        se_action,
        replace(replace(se_label, '%40', '@'), '%2B', '+') as se_label,
        se_property,
        se_value,
        tr_orderid,
        tr_affiliation,
        tr_total,
        tr_tax,
        tr_shipping,
        tr_city,
        tr_state,
        tr_country,
        ti_orderid,
        ti_sku,
        ti_name,
        ti_category,
        ti_price,
        ti_quantity,
        pp_xoffset_min,
        pp_xoffset_max,
        pp_yoffset_min,
        pp_yoffset_max,
        tr_currency,
        ti_currency,
        refr_urlquery,
        page_referrer,
        page_title,
        useragent,

        -- Missing from Fivetran -- injected above
        dvce_created_tstamp,
        etl_tstamp,
        geo_country,
        geo_region,
        geo_city,
        geo_zipcode,
        geo_latitude,
        geo_longitude,
        geo_timezone,
        dvce_screenwidth,
        mkt_clickid,
        mkt_network,
        derived_tstamp,
        geo_region_name,

        null as ip_isp,
        null as ip_organization,
        null as ip_domain,
        null as ip_netspeed,

        null as browser,
        null as browser_name,
        null as browser_major_version,
        null as browser_minor_version,
        null as browser_build_version,
        null as browser_engine,
        null as browser_language,

        case
            when ({{br_viewwidth}}) > 100000 then null
            else {{br_viewwidth}}
        end as br_viewwidth,

        case
            when ({{br_viewheight}}) > 100000 then null
            else {{br_viewheight}}
        end as br_viewheight

    from fixed

)

select * from renamed
