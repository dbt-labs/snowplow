with base as (

select

  session_week,
  count(*) as sessions,
  count(distinct inferred_user_id) as distinct_users,
  sum(case when user_bounced = 'true' then 1 else 0 end) as bounced

from analytics.snowplow_sessions
  group by 1
)

select

  *,
  bounced/sessions::float as bounce_rate

from base
  order by 1 desc

/*

Visualizations to build off of this query:

1) Big Number 'Last Week Sessions'
    Value: sessions
    Aggregate: Last Value
    Sort by: session_week Ascending
    Trend: Rate of change, Compare To: Previous value

2) Big Number 'Last Week Uniques'
    Value: distinct_users
    Aggregate: Last Value
    Sort by: session_week Ascending
    Trend: Rate of change, Compare To: Previous value

3) Big Number 'Last Week Bounce Rate'
    Value: bounce_rate
    Aggregate: Last Value
    Sort by: session_week Ascending
    Trend: Rate of change, Compare To: Previous value \

4) Line Graph 'Sessions'
    X-axis: session_week
    Y-Axis: SUM(sessions)
    Filters: session_week

*/
