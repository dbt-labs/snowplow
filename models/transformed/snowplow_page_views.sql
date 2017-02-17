
{{
    config({
        "materialized" : "incremental",
        "dist"  : "domain_userid",
        "sort"  : ["domain_userid", "domain_sessionidx", "first_touch_tstamp"],
        "unique_key"   : "domain_userid || '-' || domain_sessionidx",
        "sql_where"    : "last_touch_tstamp > (select max(first_touch_tstamp) from {{this}})"
    })
}}

-- Page views:
-- (a) aggregate events into page views
-- (b) select all

WITH enriched_events as (

    select * from {{ ref('snowplow_enriched_events') }}

),
basic AS (

  -- (a) aggregate events into page views

  SELECT

    blended_user_id,
    inferred_user_id,
    domain_userid,
    domain_sessionidx,
    page_urlhost,
    page_urlpath,

    MIN(collector_tstamp) AS first_touch_tstamp,
    MAX(collector_tstamp) AS last_touch_tstamp,
    MIN(dvce_created_tstamp) AS min_dvce_created_tstamp, -- used to replace SQL window functions
    MAX(dvce_created_tstamp) AS max_dvce_created_tstamp, -- used to replace SQL window functions
    MAX(etl_tstamp) AS max_etl_tstamp, -- for debugging

    COUNT(*) AS event_count,
    SUM(CASE WHEN event = 'page_view' THEN 1 ELSE 0 END) AS page_view_count,
    SUM(CASE WHEN event = 'page_ping' THEN 1 ELSE 0 END) AS page_ping_count,
    COUNT(DISTINCT(FLOOR(EXTRACT (EPOCH FROM dvce_created_tstamp)/30)))/2::FLOAT AS time_engaged_with_minutes

  FROM enriched_events

  WHERE event IN ('page_view','page_ping')
    AND page_urlhost IS NOT NULL -- remove incorrect page views
    AND page_urlpath IS NOT NULL -- remove incorrect page views

  GROUP BY 1,2,3,4,5,6
  ORDER BY 1,2,3,4,7

)

-- (b) select all

SELECT

  b.blended_user_id,
  b.inferred_user_id,
  b.domain_userid,
  b.domain_sessionidx,
  b.page_urlhost,
  b.page_urlpath,

  b.first_touch_tstamp,
  b.last_touch_tstamp,
  b.min_dvce_created_tstamp,
  b.max_dvce_created_tstamp,
  b.max_etl_tstamp,

  b.event_count,
  b.page_view_count,
  b.page_ping_count,
  b.time_engaged_with_minutes

  FROM basic AS b
