-- This one is a little tougher to make incremental
-- because there's no timestamp field here. We could
-- relocate the event collector_tstamp (by root_id)
-- onto snowplow_base_web_page_context, but that would
-- likely mitigate any performance gains!

{{
    config(
        materialized='table',
        sort='page_view_id',
        dist='page_view_id'
    )
}}

with web_page_context as (

    select * from {{ ref('snowplow_base_web_page_context') }}

),

prep as (

    select
        root_id,
        -- The context table doesn't have an ID besides `root_id`, so
        -- we need a unique reference to the context
        id as page_view_id

    from web_page_context
    group by 1,2

),

duplicated as (

    select
        root_id

    from prep
    group by 1
    having count(*) > 1

)

select * from prep where root_id not in (select root_id from duplicated)