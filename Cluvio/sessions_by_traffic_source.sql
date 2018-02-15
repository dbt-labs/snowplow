
select

  {session_start:aggregation} as session_start,
  device_type,
  count(*) as sessions

from analytics.snowplow_sessions
  [snowplow_traffic_filters]
  group by 1,2
  order by 1

  /*

  Type: Line
  Session Start: X
  App Id: -
  Device Type: Group
  Sessions: Y

  */
