
{{
    config({
        "materialized" : "incremental",
        "dist"      : "domain_userid",
        "sort"      : "domain_userid",
        "sql_where"    : "collector_tstamp > ( select max(collector_tstamp) from {{this}} )"
    })
}}

-- Identity stitching:
-- (a) select max device timestamp
-- (b) select the most recent user ID associated with each cookie and deduplicate
-- (c) select the updated rows
-- (d) select the rows that were not updated


WITH events as (

    select * from {{ var('events_table') }}

),
stitching_1 AS (

    -- (a) select max device timestamp

    SELECT

      domain_userid,
      MAX(dvce_created_tstamp) AS max_dvce_created_tstamp -- the last event where user ID was not NULL

    FROM events

    WHERE user_id IS NOT NULL -- restrict to cookies with a user ID

      AND domain_userid != ''           -- do not aggregate missing values
      AND domain_userid IS NOT NULL     -- do not aggregate NULL
      AND domain_sessionidx IS NOT NULL -- do not aggregate NULL
      AND collector_tstamp IS NOT NULL  -- not required
      AND dvce_created_tstamp IS NOT NULL       -- not required

      AND dvce_created_tstamp < collector_tstamp + interval '52 weeks' -- remove outliers (can cause errors)
      AND dvce_created_tstamp > collector_tstamp - interval '52 weeks' -- remove outliers (can cause errors)

    --AND app_id = 'production'
    --AND platform = ''
    --AND page_urlhost = ''
    --AND page_urlpath IS NOT NULL

    GROUP BY 1

), stitching_2 AS (

    -- (b) select the most recent user ID associated with each cookie and deduplicate

    SELECT * FROM (
        SELECT

            a.domain_userid,
            a.user_id,
            a.collector_tstamp,

            ROW_NUMBER() OVER (PARTITION BY a.domain_userid) AS row_number

        FROM events AS a

        INNER JOIN stitching_1 AS b
            ON  a.domain_userid = b.domain_userid
            AND a.dvce_created_tstamp = b.max_dvce_created_tstamp -- replaces the LAST VALUE window function in SQL

    ) sbq WHERE row_number = 1 -- deduplicate

)

-- (c) select the updated rows

SELECT
    collector_tstamp,
    domain_userid,
    user_id AS inferred_user_id
FROM stitching_2
