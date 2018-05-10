
{% macro snowplow_web_events_scroll_depth() %}

    {{ adapter_macro('snowplow.snowplow_web_events_scroll_depth') }}

{% endmacro %}


{% macro default__snowplow_web_events_scroll_depth() %}

{{
    config(
        materialized='incremental',
        sort='page_view_id',
        dist='page_view_id',
        sql_where='TRUE',
        unique_key='page_view_id'
    )
}}

{# cache this because we need it below too #}
{% set this_exists = adapter.already_exists(this.schema, this.name) and not flags.FULL_REFRESH%}

with all_events as (

    select * from {{ ref('snowplow_base_events') }}

),

events as (

    select * from all_events
    {% if this_exists %}
    where collector_tstamp > (
        select coalesce(max(max_tstamp), '0001-01-01') from {{ this }}
    )
    {% endif %}

),

web_page_context as (

    select * from {{ ref('snowplow_web_page_context') }}

),

prep as (

    select

        wp.page_view_id,

        max(ev.collector_tstamp) as max_tstamp,

        max(ev.doc_width) as doc_width,
        max(ev.doc_height) as doc_height,

        max(ev.br_viewwidth) as br_viewwidth,
        max(ev.br_viewheight) as br_viewheight,

        least(greatest(min(coalesce(ev.pp_xoffset_min, 0)), 0), max(ev.doc_width)) as hmin,
        least(greatest(max(coalesce(ev.pp_xoffset_max, 0)), 0), max(ev.doc_width)) as hmax,

        least(greatest(min(coalesce(ev.pp_yoffset_min, 0)), 0), max(ev.doc_height)) as vmin,
        least(greatest(max(coalesce(ev.pp_yoffset_max, 0)), 0), max(ev.doc_height)) as vmax

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
        max_tstamp,

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

),

{% if this_exists %}

relevant_existing as (

    select
        page_view_id,
        max_tstamp,
        doc_width,
        doc_height,
        br_viewwidth,
        br_viewheight,
        hmin,
        hmax,
        vmin,
        vmax,
        relative_hmin,
        relative_hmax,
        relative_vmin,
        relative_vmax
    from {{ this }}
    where page_view_id in (select page_view_id from relative)
),

unioned as (

    select
        page_view_id,
        max_tstamp,
        doc_width,
        doc_height,
        br_viewwidth,
        br_viewheight,
        hmin,
        hmax,
        vmin,
        vmax,
        relative_hmin,
        relative_hmax,
        relative_vmin,
        relative_vmax
    from relative

    union all

    select
        page_view_id,
        max_tstamp,
        doc_width,
        doc_height,
        br_viewwidth,
        br_viewheight,
        hmin,
        hmax,
        vmin,
        vmax,
        relative_hmin,
        relative_hmax,
        relative_vmin,
        relative_vmax
    from relevant_existing

),


merged as (

    select
        page_view_id,
        max(max_tstamp) as max_tstamp,
        max(doc_width) as doc_width,
        max(doc_height) as doc_height,
        max(br_viewwidth) as br_viewwidth,
        max(br_viewheight) as br_viewheight,
        max(hmin) as hmin,
        max(hmax) as hmax,
        max(vmin) as vmin,
        max(vmax) as vmax,
        max(relative_hmin) as relative_hmin,
        max(relative_hmax) as relative_hmax,
        max(relative_vmin) as relative_vmin,
        max(relative_vmax) as relative_vmax

    from unioned
    group by 1


)

{% else %}

merged as (

    select * from relative

)

{% endif %}

select * from merged

{% endmacro %}
