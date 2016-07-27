with events as (

  select * from {{ref('events')}}

)

select *
from events
where event = 'pv'
