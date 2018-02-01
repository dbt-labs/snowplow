select

  session_week,
  case when session_index = 1 then 'new' else 'returning' end as new_vs_returning,
  count(*) as count_new_returning

from analytics.snowplow_sessions
  group by 1,2
  order by 1 desc

/*

Visualization to build off of this query:

Donut 'New vs Returning Sessions'
    Value: sessions
    Color: new_vs_returning
    Angle: SUM(count_new_returning)
    Filters: session_week

*/
