select

  case when session_index = 1 then 'new' else 'returning' end as new_vs_returning,
  count(*) as count_new_returning

from analytics.snowplow_sessions
  [snowplow_traffic_filters]
  group by 1

  /*

  Type: Donut
  New Vs Returning: Labels
  Count New Returning: Values
  Value Formatting: 123
  Additional Options:
    Max number of values: 2
    Max legend label width (chars): 20
    Legend: Value (%)

  */
