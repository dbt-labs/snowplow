with events as (

  select * from {{ref('events')}}

), sessions_basic as (

  select * from {{ref('sessions_basic')}}

), d1 as (

  select -- select the last page (using dvce_tstamp)
    a.domain_userid,
    a.domain_sessionidx,
    a.page_urlhost,
    a.page_urlpath,
    rank() over (partition by a.domain_userid, a.domain_sessionidx order by a.page_urlhost, a.page_urlpath) as rank
  from events as a
  inner join sessions_basic as b
    on  a.domain_userid = b.domain_userid
    and a.domain_sessionidx = b.domain_sessionidx
    and a.dvce_tstamp = b.dvce_max_tstamp
  group by 1,2,3,4 -- aggregate identital rows (that happen to have the same dvce_tstamp)

)

select *
from d1
where rank = 1 -- if there are different rows with the same dvce_tstamp, rank and pick the first row
