
{{ config(materialized='table', sort='page_view_id', dist='page_view_id') }}


with ua_parser_context as (

    select * from {{ ref('snowplow_base_useragent_context') }}

),

web_page_context as (

    select * from {{ ref('snowplow_web_page_context') }}

),

prep AS (

    SELECT

      wp.page_view_id,

      ua.useragent_family,
      ua.useragent_major,
      ua.useragent_minor,
      ua.useragent_patch,
      ua.useragent_version,
      ua.os_family,
      ua.os_major,
      ua.os_minor,
      ua.os_patch,
      ua.os_patch_minor,
      ua.os_version,
      ua.device_family

    from ua_parser_context as ua
        inner join web_page_context as wp on ua.root_id = wp.root_id

    group by 1,2,3,4,5,6,7,8,9,10,11,12,13

),

duplicated as (

    select
      page_view_id

    from prep

    group by 1
    having count(*) > 1

)

select
  page_view_id,
  useragent_family,
  useragent_major,
  useragent_minor,
  useragent_patch,
  useragent_version,
  os_family,
  os_major,
  os_minor,
  os_patch,
  os_patch_minor,
  os_version,
  device_family
from prep
where page_view_id not in (select page_view_id from duplicated)
