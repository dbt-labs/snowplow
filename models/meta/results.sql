{{
    config({
        "materialized" : "incremental",
        "sql_where"    : "max_tstamp > (select max(max_tstamp) from {{this}})"
    })
}}

-- This model depends on:

-- {{ ref('page_views') }}
-- {{ ref('sessions') }}
-- {{ ref('visitors') }}

SELECT

    min_tstamp,
    max_tstamp,
    component,
    step,
    tstamp,
    EXTRACT(EPOCH FROM (tstamp - previous_tstamp)) AS duration

FROM (

    SELECT

      FIRST_VALUE(tstamp) OVER (ORDER BY tstamp ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS min_tstamp,
      LAST_VALUE(tstamp) OVER (ORDER BY tstamp ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS max_tstamp,

      component,
      step,
      tstamp,

      LAG(tstamp, 1) OVER (ORDER BY tstamp) AS previous_tstamp

    FROM {{ ref('queries') }}

    ORDER BY tstamp

) sbq

WHERE component != 'main'
ORDER BY tstamp
