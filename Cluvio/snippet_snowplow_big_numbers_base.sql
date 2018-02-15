/* this is a snippet with the CTE that defines fields needed for the three big numbers at the top
of the report*/

with base as (

select

  session_week,
  app_id,
  count(*) as sessions,
  count(distinct inferred_user_id) as distinct_users,
  sum(case when user_bounced = 'true' then 1 else 0 end) as bounced

from analytics.snowplow_sessions
  group by 1,2
  
)

select
  *,
  bounced/sessions::float as bounce_rate
from base
  WHERE {app_id = store_filter}
  order by 1 desc
  limit 1
  offset 1

/*
big number 1:
