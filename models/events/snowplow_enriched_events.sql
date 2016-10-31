
{{
    config({
        "materialized" : "incremental",
        "distkey"  : "domain_userid",
        "sortkey"  : ["collector_tstamp"],
        "sql_where"    : "collector_tstamp > (select max(collector_tstamp) from {{this}})"
    })
}}

-- Enrich events:

WITH events AS (

  -- (a) select the columns we need and deduplicate events

  SELECT * FROM (
    SELECT

      COALESCE(u.inferred_user_id, e.domain_userid) AS blended_user_id,
      u.inferred_user_id,

      e.domain_userid,
      e.domain_sessionidx,

      e.event_id, -- for deduplication
      e.event, -- for filtering

      e.collector_tstamp,
      e.dvce_created_tstamp,
      e.etl_tstamp, -- for debugging

      e.geo_country,
      e.geo_region,
      e.geo_city,
      e.geo_zipcode,
      e.geo_latitude,
      e.geo_longitude,

      e.page_urlhost,
      e.page_urlpath,

      e.mkt_source,
      e.mkt_medium,
      e.mkt_term,
      e.mkt_content,
      e.mkt_campaign,
      e.refr_source,
      e.refr_medium,
      e.refr_term,
      e.refr_urlhost,
      e.refr_urlpath,

      e.br_name,
      e.br_family,
      e.br_version,
      e.br_type,
      e.br_renderengine,
      e.br_lang,
      e.br_features_director,
      e.br_features_flash,
      e.br_features_gears,
      e.br_features_java,
      e.br_features_pdf,
      e.br_features_quicktime,
      e.br_features_realplayer,
      e.br_features_silverlight,
      e.br_features_windowsmedia,
      e.br_cookies,
      e.os_name,
      e.os_family,
      e.os_manufacturer,
      e.os_timezone,
      e.dvce_type,
      e.dvce_ismobile,
      e.dvce_screenwidth,
      e.dvce_screenheight,

      ROW_NUMBER() OVER (PARTITION BY event_id) as event_number -- select one event at random if the ID is duplicated

    FROM {{ var('events_table') }} as e

    LEFT JOIN {{ ref('snowplow_id_map') }} AS u ON u.domain_userid = e.domain_userid

    WHERE e.domain_userid != ''           -- do not aggregate missing values
      AND e.domain_userid IS NOT NULL     -- do not aggregate NULL
      AND e.domain_sessionidx IS NOT NULL -- do not aggregate NULL
      AND e.collector_tstamp IS NOT NULL  -- not required
      AND e.dvce_created_tstamp IS NOT NULL       -- not required

      AND e.dvce_created_tstamp < e.collector_tstamp + interval '52 weeks' -- remove outliers (can cause errors)
      AND e.dvce_created_tstamp > e.collector_tstamp - interval '52 weeks' -- remove outliers (can cause errors)

    --AND e.app_id = 'production'
    --AND e.platform = ''
    --AND e.page_urlhost = ''
    --AND e.page_urlpath IS NOT NULL

  ) sbq WHERE event_number = 1

)

SELECT * from events
