with events as (

  select * from {{ref('events')}}

)

select
  domain_userid,
  domain_sessionidx,
  min(collector_tstamp) as session_start_tstamp,
  max(collector_tstamp) as session_end_tstamp,
  min(dvce_tstamp) as dvce_min_tstamp,
  max(dvce_tstamp) as dvce_max_tstamp,
  count(*) as event_count,
  count(distinct(floor(extract(epoch from dvce_tstamp)/30)))/2::float as time_engaged_with_minutes
from
  events
where domain_sessionidx is not null
  and domain_userid is not null
  and domain_userid != ''
  and dvce_tstamp is not null
group by 1,2
