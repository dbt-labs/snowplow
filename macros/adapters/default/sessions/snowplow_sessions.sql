
{% macro snowplow_sessions() %}

    {{ adapter_macro('snowplow.snowplow_sessions') }}

{% endmacro %}


{% macro default__snowplow_sessions() %}

{{
    config(
        materialized='table',
        sort='session_start',
        dist='user_snowplow_domain_id'
    )
}}

with snowplow_sessions as (

    select * from {{ ref('snowplow_sessions_tmp') }}

),

id_map as (

    select * from {{ ref('snowplow_id_map') }}

),

stitched as (

    select
        user_custom_id,
        coalesce(id.user_id, user_snowplow_domain_id) as inferred_user_id,
        user_snowplow_domain_id,
        user_snowplow_crossdomain_id,

        app_id,
        bounced_page_views,
        browser,
        browser_build_version,
        browser_engine,
        browser_language,
        browser_major_version,
        browser_minor_version,
        browser_name,
        device,
        device_is_mobile,
        device_type,
        first_page_title,
        first_page_url,
        first_page_url_fragment,
        first_page_url_host,
        first_page_url_path,
        first_page_url_port,
        first_page_url_query,
        first_page_url_scheme,
        exit_page_url,
        geo_city,
        geo_country,
        geo_latitude,
        geo_longitude,
        geo_region,
        geo_region_name,
        geo_timezone,
        geo_zipcode,
        ip_address,
        ip_domain,
        ip_isp,
        ip_net_speed,
        ip_organization,
        marketing_campaign,
        marketing_click_id,
        marketing_content,
        marketing_medium,
        marketing_network,
        marketing_source,
        marketing_term,
        os,
        os_build_version,
        os_major_version,
        os_manufacturer,
        os_minor_version,
        os_name,
        os_timezone,
        page_views,
        referer_medium,
        referer_source,
        referer_term,
        referer_url,
        referer_url_fragment,
        referer_url_host,
        referer_url_path,
        referer_url_port,
        referer_url_query,
        referer_url_scheme,
        session_start,
        session_start_local,
        session_end,
        session_end_local,
        session_id,
        session_index as session_cookie_index,
        time_engaged_in_s,
        time_engaged_in_s_tier,
        user_bounced

    from snowplow_sessions as s
    left outer join id_map as id on s.user_snowplow_domain_id = id.domain_userid

)

select
    *,
    row_number() over (partition by inferred_user_id order by session_start) as session_index

from stitched

{% endmacro %}
