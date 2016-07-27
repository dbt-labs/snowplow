with events as (

  select * from {{ref('events')}}

), sessions_basic as (

  select * from {{ref('sessions_basic')}}

), d1 as (

  select -- select campaign and referer data from the earliest row (using dvce_tstamp)
    a.domain_userid,
    a.domain_sessionidx,
    mkt_source,
    mkt_medium,
    mkt_term,
    mkt_content,
    mkt_campaign,
    refr_urlhost,
    refr_urlpath,
    rank() over (partition by a.domain_userid, a.domain_sessionidx
      order by a.mkt_source, a.mkt_medium, a.mkt_term, a.mkt_content, a.mkt_campaign) as rank
  from events as a
  inner join sessions_basic as b
    on  a.domain_userid = b.domain_userid
  where (coalesce(mkt_source, mkt_medium, mkt_term, mkt_content, mkt_campaign, refr_urlhost, refr_urlpath) is not null
      or coalesce(mkt_source, mkt_medium, mkt_term, mkt_content, mkt_campaign, refr_urlhost, refr_urlpath) != '')
    and a.domain_sessionidx = b.domain_sessionidx
    and a.dvce_tstamp = b.dvce_min_tstamp
  group by 1,2,3,4,5,6,7,8,9 -- aggregate identital rows (that happen to have the same dvce_tstamp)

)

select *
from d1
where rank = 1
