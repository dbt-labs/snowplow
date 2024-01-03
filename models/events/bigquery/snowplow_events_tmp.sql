{{
    config(
        materialized='incremental',
        partition_by={
            'field': 'collector_timestamp',
            'data_type': 'timestamp'
        },
        unique_key='event_id',
        cluster_by='event_id',
        enabled=is_adapter('bigquery')
    )
}}

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
        row_number() over (
            partition by event_id
            order by dvce_created_tstamp, collector_tstamp
        ) as dedupe

    from all_events
    where domain_sessionid is not null

),

dedupes as (

    select * from relevant_events as e
    where dedupe = 1

)

select
    -- app & platform
    app_id,
    platform,

    -- timestamps
    etl_tstamp as etl_timestamp,
    collector_tstamp as collector_timestamp,
    dvce_created_tstamp as device_created_timestamp,
    dvce_sent_tstamp as device_sent_timestamp,
    refr_dvce_tstamp as referer_device_timestamp,
    derived_tstamp as derived_timestamp,
    true_tstamp as true_timestamp,

    -- event
    event as event_type,
    event_id,
    event_vendor,
    event_name,
    event_format,
    event_version,
    event_fingerprint,

    -- namespacing and versioning
    name_tracker as tracker_name,
    v_tracker as tracker_version,
    v_collector as collector_version,
    v_etl as etl_version,

    -- user
    user_id,
    domain_userid as user_snowplow_domain_id,
    network_userid as user_snowplow_crossdomain_id,

    -- session
    domain_sessionid as session_id,
    domain_sessionidx as session_index,

    -- IP address
    struct(
        user_ipaddress as address,
        ip_isp as isp,
        ip_organization as organization,
        ip_domain as domain,
        ip_netspeed as netspeed
    ) as ip,

    -- page
    struct(
        page_url as url,
        page_title as title,
        page_referrer as referer,
        page_urlscheme as url_scheme,
        page_urlhost as url_host,
        page_urlport as url_port,
        page_urlpath as url_path,
        page_urlquery as url_query,
        page_urlfragment as url_fragment
    ) as page,

    -- referer
    struct(
        refr_medium as medium,
        refr_source as source,
        refr_term as term,
        refr_domain_userid as domain_user_id,
        refr_urlscheme as url_scheme,
        refr_urlhost as url_host,
        refr_urlport as url_port,
        refr_urlpath as url_path,
        refr_urlquery as url_query,
        refr_urlfragment as url_fragment
    ) as referer,

    -- standard event params
    se_category as event_category,
    se_action as event_action,
    se_label as event_label,
    se_property as event_property,
    se_value as event_value,

    -- transaction
    struct(
        tr_orderid as order_id,
        tr_affiliation as affiliation,
        tr_total as total,
        tr_tax as tax,
        tr_shipping as shipping,
        tr_city as city,
        tr_state as state,
        tr_country as country,
        tr_currency as currency,
        tr_total_base as total_base,
        tr_tax_base as tax_base,
        tr_shipping_base as shipping_base
    ) as transaction,

    -- transaction item
    struct(
        ti_orderid as order_id,
        ti_sku as sku,
        ti_name as name,
        ti_category as category,
        ti_price as price,
        ti_quantity as quantity,
        ti_currency as currency,
        ti_price_base as price_base
    ) as transaction_item,

    -- marketing
    struct(
        mkt_medium as medium,
        mkt_source as source,
        mkt_term as term,
        mkt_content as content,
        mkt_campaign as campaign,
        mkt_clickid as click_id,
        mkt_network as network,
        mkt_channel as channel
    ) as marketing,

    -- location
    struct(
        geo_country as country,
        geo_region as region,
        geo_region_name as region_name,
        geo_city as city,
        geo_zipcode as zipcode,
        geo_latitude as latitude,
        geo_longitude as longitude,
        geo_timezone as timezone
    ) as geo,

    -- user agent
    useragent as user_agent

    -- custom columns
    {%- if var('snowplow:pass_through_columns') | length > 0 %}
    , struct(
        {{ var('snowplow:pass_through_columns') | join(',\n') }}
    ) as custom
    {% endif %}

from dedupes
where (br_family != 'Robot/Spider' or br_family is null)
    and (
        {% set bad_agents_psv = bot_any()|join('|') %}
        not regexp_contains(LOWER(useragent), '^.*({{bad_agents_psv}}).*$')
        or useragent is null
    )
    and domain_userid is not null
    and domain_sessionidx > 0