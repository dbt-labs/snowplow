select

  session_week,
  time_engaged_in_s_tier,
  count(*) as sessions

from analytics.snowplow_sessions
  group by 1,2

/*

Visualization to build off of this query:

Line graph 'Sessions by Traffic Source'
    X-Axis: time_engaged_in_s_tier
    Y-Axis: Sum(sessions)
    Filters: session_week

*/
