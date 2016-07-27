with events as (

  select * from {{ref('events')}}

), sessions_basic as (

  select * from {{ref('sessions_basic')}}

), d1 as (

  select -- select the last page (using dvce_tstamp)
    a.domain_userid,
    a.domain_sessionidx,
    a.br_lang,
    a.br_features_director,
    a.br_features_flash,
    a.br_features_gears,
    a.br_features_java,
    a.br_features_pdf,
    a.br_features_quicktime,
    a.br_features_realplayer,
    a.br_features_silverlight,
    a.br_features_windowsmedia,
    a.br_cookies,
    a.os_name,
    a.os_family,
    a.os_manufacturer,
    a.os_timezone,
    a.dvce_type,
    a.dvce_ismobile,
    a.dvce_screenheight,
    rank() over (partition by a.domain_userid, a.domain_sessionidx
      order by a.br_lang,
        a.br_features_director, a.br_features_flash, a.br_features_gears, a.br_features_java,
        a.br_features_pdf, a.br_features_quicktime, a.br_features_realplayer, a.br_features_silverlight,
        a.br_features_windowsmedia, a.br_cookies, a.os_name, a.os_family, a.os_manufacturer, a.os_timezone,
        a.dvce_type, a.dvce_ismobile, a.dvce_screenheight) as rank
  from events as a
  inner join sessions_basic as b
    on  a.domain_userid = b.domain_userid
    and a.domain_sessionidx = b.domain_sessionidx
    and a.dvce_tstamp = b.dvce_min_tstamp
  group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20 -- aggregate identital rows

)

select *
from d1
where rank = 1 -- if there are different rows with the same dvce_tstamp, rank and pick the first row
