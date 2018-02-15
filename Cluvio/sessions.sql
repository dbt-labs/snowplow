with base as (

select

  {session_start:aggregation} as session_start,
  app_id,
  count(*) as sessions

from analytics.snowplow_sessions
  group by 1,2
)

select
  *
from base
  [snowplow_traffic_filters]
  order by 1

  /*

  Type: Line
  Session Start: X
  App Id: Group
  Sessions: Y

  */
