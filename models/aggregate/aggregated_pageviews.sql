
{{
    config({
        "distkey"      : "domain_userid",
        "sortkey"      : ["domain_userid", "domain_sessionidx", "first_touch_tstamp"],
        "post-hook"    : "INSERT INTO {{ ref('queries') }} (SELECT 'page-views', 'aggregate', {{ var('now') }} )" ,
        "unique_key"   : "domain_userid || '-' || domain_sessionidx",
        "sql_where"    : "last_touch_tstamp > (select max(first_touch_tstamp) from {{this}})",
        "materialized" : "incremental"
    })
}}

-- Aggregate new and old rows:
-- (a) calculate aggregate frame (i.e. a GROUP BY)
-- (b) calculate final frame (i.e. last value)
-- (c) combine

WITH aggregate_frame AS (

  -- (a) calculate aggregate frame (i.e. a GROUP BY)

  SELECT

    domain_userid,
    domain_sessionidx,
    page_urlhost,
    page_urlpath,

    MIN(first_touch_tstamp) AS first_touch_tstamp,
    MAX(last_touch_tstamp) AS last_touch_tstamp,
    MIN(min_dvce_created_tstamp) AS min_dvce_created_tstamp, -- used to replace SQL window functions
    MAX(max_dvce_created_tstamp) AS max_dvce_created_tstamp, -- used to replace SQL window functions
    MAX(max_etl_tstamp) AS max_etl_tstamp, -- for debugging
    SUM(event_count) AS event_count,
    SUM(page_view_count) AS page_view_count,
    SUM(page_ping_count) AS page_ping_count,
    SUM(time_engaged_with_minutes) AS time_engaged_with_minutes

  FROM {{ ref('page_views') }}
  GROUP BY 1,2,3,4
  ORDER BY 1,2,3,4

), final_frame AS (

  -- (b) calculate final frame (i.e. last value)

  SELECT * FROM (
    SELECT

      a.domain_userid,
      a.domain_sessionidx,
      a.page_urlhost,
      a.page_urlpath,

      a.blended_user_id, -- edge case: one page view with multiple logins and events in several batches
      a.inferred_user_id, -- edge case: one page view with multiple logins and events in several batches

      ROW_NUMBER() OVER (PARTITION BY a.domain_userid, a.domain_sessionidx, a.page_urlhost, a.page_urlpath) AS row_number

    FROM {{ ref('page_views') }} AS a

    INNER JOIN aggregate_frame AS b
      ON  a.domain_userid = b.domain_userid
      AND a.domain_sessionidx = b.domain_sessionidx
      AND a.page_urlhost = b.page_urlhost
      AND a.page_urlpath = b.page_urlpath
      AND a.max_dvce_created_tstamp = b.max_dvce_created_tstamp

    ORDER BY 1,2,3,4,5,6
  ) sbq
  WHERE row_number = 1 -- deduplicate

)

-- (c) combine and insert into derived

SELECT

  f.blended_user_id,
  f.inferred_user_id,

  a.domain_userid,
  a.domain_sessionidx,
  a.page_urlhost,
  a.page_urlpath,

  a.first_touch_tstamp,
  a.last_touch_tstamp,
  a.min_dvce_created_tstamp,
  a.max_dvce_created_tstamp,
  a.max_etl_tstamp,
  a.event_count,
  a.page_view_count,
  a.page_ping_count,
  a.time_engaged_with_minutes

FROM aggregate_frame AS a

LEFT JOIN final_frame AS f
  ON  a.domain_userid = f.domain_userid
  AND a.domain_sessionidx = f.domain_sessionidx
  AND a.page_urlhost = f.page_urlhost
  AND a.page_urlpath = f.page_urlpath
