
{{
    config(
        materialized='incremental',
        sort='page_view_id',
        dist='page_view_id',
        sql_where='TRUE',
        unique_key='page_view_id'
    )
}}

{{ "{% " }} set this_schema = "{{ this.schema }}" {{ " %}" }}
{{ "{% " }} set this_name = "{{ this.name }}" {{ " %}" }}


with web_page_context as (

    select * from {{ ref('snowplow_web_page_context') }}

),

events as (

    {{ snowplow.select_new_events('snowplow_base_events', this.schema, this.name, "max_tstamp") }}

),

prep as (

    select

        wp.page_view_id,

        min(ev.derived_tstamp) as min_tstamp,
        max(ev.derived_tstamp) as max_tstamp,

        sum(case when ev.event_name = 'page_view' then 1 else 0 end) as pv_count,
        sum(case when ev.event_name = 'page_ping' then 1 else 0 end) as pp_count,
        (sum(case when ev.event_name = 'page_ping' then 1 else 0 end) * {{ var('snowplow:page_ping_frequency', 30) }}) as time_engaged_in_s

    from events as ev
        inner join web_page_context as wp on ev.event_id = wp.root_id

    where ev.event_name in ('page_view', 'page_ping')
    group by 1

),

{% raw %}

    {% if already_exists(this_schema, this_name) %}

relevant_existing as (

    select
        page_view_id,
        min_tstamp,
        max_tstamp,
        pv_count,
        pp_count,
        time_engaged_in_s

    from "{{ this_schema }}"."{{ this_name }}"
    where page_view_id in (select page_view_id from prep)

),

unioned as (

    select
        page_view_id,
        min_tstamp,
        max_tstamp,
        pv_count,
        pp_count,
        time_engaged_in_s
    from prep

    union all

    select
        page_view_id,
        min_tstamp,
        max_tstamp,
        pv_count,
        pp_count,
        time_engaged_in_s
    from relevant_existing

),

merged as (

    select
        page_view_id,
        min(min_tstamp) as min_tstamp,
        max(max_tstamp) as max_tstamp,
        sum(pv_count) as pv_count,
        sum(pp_count) as pp_count,
        sum(time_engaged_in_s) as time_engaged_in_s

    from unioned
    group by 1


)

    {% else %}

-- initial run, don't merge
merged as (

    select * from prep

)

    {% endif %}

{% endraw %}

select * from merged
