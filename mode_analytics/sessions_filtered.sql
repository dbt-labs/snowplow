select

  session_week,
  referer_medium,
  device_type,
  count(*) as sessions

from analytics.snowplow_sessions
  group by 1,2,3
  order by 1


/*

Visualizations to build off of this query:

1) Line graph 'Sessions by Traffic Source'
    X-Axis: session_week
    Y-Axis: Sum(sessions)
    Color: referer_medium
    Filters: session_week

*/
