select

   case when time_engaged_in_s_tier = '0s to 9s' then 'a.  0 to 9 seconds'
        when time_engaged_in_s_tier = '10s to 29s' then 'b.  10 to 29 seconds'
        when time_engaged_in_s_tier = '30s to 59s' then 'c.  30 to 59 seconds'
        when time_engaged_in_s_tier = '60s to 119s' then 'd.  90 to 119 seconds'
        when time_engaged_in_s_tier = '120s to 239s' then 'e.  120 to 239 seconds'
        when time_engaged_in_s_tier = '240s or more' then 'f.  240 seconds or more'
   end as session_length,
  count(*) as sessions

from analytics.snowplow_sessions
   [snowplow_traffic_filters]
  group by 1
  order by 1

  /*

  Type: Bar (Horizontal)
  Session Length: X
  Sessions: Y

  */
