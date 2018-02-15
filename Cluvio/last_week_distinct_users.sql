/* uses the snippet defined in snowplow_big_numbers_base */

[snowplow_big_numbers_base]

select
  session_week,
  app_id,
  distinct_users
from base
  WHERE {app_id = store_filter}
  order by 1 desc

  /*

     Type: Number
        Value: Distinct Users
        Compare To: Previous value as percentage

  */
