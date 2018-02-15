/* uses the snippet defined in snowplow_big_numbers_base */

[snowplow_big_numbers_base]

select
  session_week,
  app_id,
  sessions
from base
  -- apply the filter for which store data is from
  where {app_id = store_filter}
  order by 1 desc -- so that the first result is the most recent full week

/*

   Type: Number
      Value: sessions
      Compare To: Previous value as percentage

*/
