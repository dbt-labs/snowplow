with events as (

  select * from {{ref('events')}}

), sessions_basic as (

  select * from {{ref('sessions_basic')}}

), sessions_exit_page as (

  select * from {{ref('sessions_exit_page')}}

), sessions_landing_page as (

  select * from {{ref('sessions_landing_page')}}

), sessions_technology as (

  select * from {{ref('sessions_technology')}}

), sessions_source as (

  select * from {{ref('sessions_source')}}

)

select
  b.domain_userid,
  b.domain_sessionidx,
  b.session_start_tstamp,
  b.session_end_tstamp,
  b.dvce_min_tstamp,
  b.dvce_max_tstamp,
  b.event_count,
  b.time_engaged_with_minutes,
  l.page_urlhost as landing_page_host,
  l.page_urlpath as landing_page_path,
  e.page_urlhost as exit_page_host,
  e.page_urlpath as exit_page_path,
  s.mkt_source,
  s.mkt_medium,
  s.mkt_term,
  s.mkt_content,
  s.mkt_campaign,
  --s.refr_source,
  --s.refr_medium,
  --s.refr_term,
  s.refr_urlhost,
  s.refr_urlpath,
  --t.br_name,
  --t.br_family,
  --t.br_version,
  --t.br_type,
  --t.br_renderengine,
  t.br_lang,
  t.br_features_director,
  t.br_features_flash,
  t.br_features_gears,
  t.br_features_java,
  t.br_features_pdf,
  t.br_features_quicktime,
  t.br_features_realplayer,
  t.br_features_silverlight,
  t.br_features_windowsmedia,
  t.br_cookies,
  t.os_name,
  t.os_family,
  t.os_manufacturer,
  t.os_timezone,
  t.dvce_type,
  t.dvce_ismobile,
  --t.dvce_screenwidth,
  t.dvce_screenheight
from sessions_basic as b
left join sessions_landing_page as l
  on  b.domain_userid = l.domain_userid
  and b.domain_sessionidx = l.domain_sessionidx
left join sessions_exit_page as e
  on  b.domain_userid = e.domain_userid
  and b.domain_sessionidx = e.domain_sessionidx
left join sessions_source as s
  on  b.domain_userid = s.domain_userid
  and b.domain_sessionidx = s.domain_sessionidx
left join sessions_technology as t
  on  b.domain_userid = t.domain_userid
  and b.domain_sessionidx = t.domain_sessionidx
