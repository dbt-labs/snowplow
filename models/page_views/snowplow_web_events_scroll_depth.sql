
{{
    config(
        materialized='table',
        sort='page_view_id',
        dist='page_view_id'
    )
}}


with events as (

    select * from {{ ref('snowplow_base_events') }}

),

web_page_context as (

    select * from {{ ref('snowplow_web_page_context') }}

),

prep as (

    select

        wp.page_view_id,

        max(ev.doc_width) as doc_width,
        max(ev.doc_height) as doc_height,

        max(ev.br_viewwidth) as br_viewwidth,
        max(ev.br_viewheight) as br_viewheight,

        least(greatest(min(nvl(ev.pp_xoffset_min, 0)), 0), max(ev.doc_width)) as hmin,
        least(greatest(max(nvl(ev.pp_xoffset_max, 0)), 0), max(ev.doc_width)) as hmax,

        least(greatest(min(nvl(ev.pp_yoffset_min, 0)), 0), max(ev.doc_height)) as vmin,
        least(greatest(max(nvl(ev.pp_yoffset_max, 0)), 0), max(ev.doc_height)) as vmax

    from events as ev
        inner join web_page_context as wp on ev.event_id = wp.root_id

    where ev.event_name in ('page_view', 'page_ping')
      and ev.doc_height > 0
      and ev.doc_width > 0

    group by 1

),

relative as (

    select

        page_view_id,

        doc_width,
        doc_height,
        br_viewwidth,
        br_viewheight,

        hmin,
        hmax,
        vmin,
        vmax,

        round(100*(greatest(hmin, 0)/doc_width::float)) as relative_hmin,
        round(100*(least(hmax + br_viewwidth, doc_width)/doc_width::float)) as relative_hmax,
        round(100*(greatest(vmin, 0)/doc_height::float)) as relative_vmin,
        round(100*(least(vmax + br_viewheight, doc_height)/doc_height::float)) as relative_vmax

    from prep

)

select * from relative
