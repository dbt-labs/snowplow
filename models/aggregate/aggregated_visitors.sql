
{{
    config({
        "distkey"      : "blended_user_id",
        "sortkey"      : "blended_user_id",
        "post-hook"    : "INSERT INTO {{ ref('queries') }} (SELECT 'visitors', 'aggregate', {{ var('now') }} )" ,
        "unique_key"   : "blended_user_id",
        "sql_where"    : "last_touch_tstamp > (select max(first_touch_tstamp) from {{this}})",
        "materialized" : "incremental"
    })
}}

-- Aggregate new and old rows:
-- (a) calculate aggregate frame (i.e. a GROUP BY)
-- (b) calculate initial frame (i.e. first value)
-- (c) combine

WITH aggregate_frame AS (

  -- (a) calculate aggregate frame (i.e. a GROUP BY)

  SELECT

    blended_user_id,

    MIN(first_touch_tstamp) AS first_touch_tstamp,
    MAX(last_touch_tstamp) AS last_touch_tstamp,
    MIN(min_dvce_created_tstamp) AS min_dvce_created_tstamp,
    MAX(max_dvce_created_tstamp) AS max_dvce_created_tstamp,
    MAX(max_etl_tstamp) AS max_etl_tstamp,
    SUM(event_count) AS event_count,
    MAX(session_count) AS session_count, -- MAX not SUM
    SUM(page_view_count) AS page_view_count,
    SUM(time_engaged_with_minutes) AS time_engaged_with_minutes

  FROM {{ ref('visitors') }}

  GROUP BY 1
  ORDER BY 1

), initial_frame AS (

  -- (b) calculate initial frame (i.e. first value)

  SELECT * FROM (
    SELECT

      a.blended_user_id,

      a.landing_page_host,
      a.landing_page_path,

      a.mkt_source,
      a.mkt_medium,
      a.mkt_term,
      a.mkt_content,
      a.mkt_campaign,
      a.refr_source,
      a.refr_medium,
      a.refr_term,
      a.refr_urlhost,
      a.refr_urlpath,

      ROW_NUMBER() OVER (PARTITION BY a.blended_user_id) AS row_number

    FROM {{ ref('visitors') }} AS a

    INNER JOIN aggregate_frame AS b
      ON  a.blended_user_id = b.blended_user_id
      AND a.min_dvce_created_tstamp = b.min_dvce_created_tstamp

    ORDER BY 1

  ) sbq
  WHERE row_number = 1 -- deduplicate

)

-- (c) combine and insert into derived

SELECT

  a.blended_user_id,

  a.first_touch_tstamp,
  a.last_touch_tstamp,
  a.min_dvce_created_tstamp,
  a.max_dvce_created_tstamp,
  a.max_etl_tstamp,
  a.event_count,
  a.session_count,
  a.page_view_count,
  a.time_engaged_with_minutes,

  i.landing_page_host,
  i.landing_page_path,

  i.mkt_source,
  i.mkt_medium,
  i.mkt_term,
  i.mkt_content,
  i.mkt_campaign,

  i.refr_source,
  i.refr_medium,
  i.refr_term,
  i.refr_urlhost,
  i.refr_urlpath

FROM aggregate_frame AS a

LEFT JOIN initial_frame AS i
  ON a.blended_user_id = i.blended_user_id
