
{{ config(materialized='table', sort='page_view_id', dist='page_view_id') }}


with performance_timing_context as (

    select * from {{ ref('snowplow_base_performance_timing_context') }}

),

web_page_context as (

    select * from {{ ref('snowplow_web_page_context') }}

),

prep as (

    select
        wp.page_view_id,

        pt.navigation_start,
        pt.redirect_start,
        pt.redirect_end,
        pt.fetch_start,
        pt.domain_lookup_start,
        pt.domain_lookup_end,
        pt.secure_connection_start,
        pt.connect_start,
        pt.connect_end,
        pt.request_start,
        pt.response_start,
        pt.response_end,
        pt.unload_event_start,
        pt.unload_event_end,
        pt.dom_loading,
        pt.dom_interactive,
        pt.dom_content_loaded_event_start,
        pt.dom_content_loaded_event_end,
        pt.dom_complete,
        pt.load_event_start,
        pt.load_event_end

    from performance_timing_context as pt
        inner join web_page_context as wp
           on pt.root_id = wp.root_id

    -- all values should be set and some have to be greater than 0 (not the case in about 1% of events)
    where pt.navigation_start is not null and pt.navigation_start > 0
      and pt.redirect_start is not null -- zero is acceptable
      and pt.redirect_end is not null -- zero is acceptable
      and pt.fetch_start is not null and pt.fetch_start > 0
      and pt.domain_lookup_start is not null and pt.domain_lookup_start > 0
      and pt.domain_lookup_end is not null and pt.domain_lookup_end > 0
      and pt.secure_connection_start is not null and pt.secure_connection_start > 0
      and pt.connect_end is not null and pt.connect_end > 0
      and pt.request_start is not null and pt.request_start > 0
      and pt.response_start is not null and pt.response_start > 0
      and pt.response_end is not null and pt.response_end > 0
      and pt.unload_event_start is not null -- zero is acceptable
      and pt.unload_event_end is not null -- zero is acceptable
      and pt.dom_loading is not null and pt.dom_loading > 0
      and pt.dom_interactive is not null and pt.dom_interactive > 0
      and pt.dom_content_loaded_event_start is not null and pt.dom_content_loaded_event_start > 0
      and pt.dom_content_loaded_event_end is not null and pt.dom_content_loaded_event_end > 0
      and pt.dom_complete is not null -- zero is acceptable
      and pt.load_event_start is not null -- zero is acceptable
      and pt.load_event_end is not null -- zero is acceptable

      -- remove rare outliers (Unix timestamp is more than twice what it should be)
      and datediff(d, pt.root_tstamp, (timestamp 'epoch' + pt.response_end/1000 * interval '1 second ')) < 365
      and datediff(d, pt.root_tstamp, (timestamp 'epoch' + pt.unload_event_start/1000 * interval '1 second ')) < 365
      and datediff(d, pt.root_tstamp, (timestamp 'epoch' + pt.unload_event_end/1000 * interval '1 second ')) < 365

),

rolledup AS (

    select
        page_view_id,

        -- select the first non-zero value
        min(nullif(navigation_start, 0)) as navigation_start,
        min(nullif(redirect_start, 0)) as redirect_start,
        min(nullif(redirect_end, 0)) as redirect_end,
        min(nullif(fetch_start, 0)) as fetch_start,
        min(nullif(domain_lookup_start, 0)) as domain_lookup_start,
        min(nullif(domain_lookup_end, 0)) as domain_lookup_end,
        min(nullif(secure_connection_start, 0)) as secure_connection_start,
        min(nullif(connect_start, 0)) as connect_start,
        min(nullif(connect_end, 0)) as connect_end,
        min(nullif(request_start, 0)) as request_start,
        min(nullif(response_start, 0)) as response_start,
        min(nullif(response_end, 0)) as response_end,
        min(nullif(unload_event_start, 0)) as unload_event_start,
        min(nullif(unload_event_end, 0)) as unload_event_end,
        min(nullif(dom_loading, 0)) as dom_loading,
        min(nullif(dom_interactive, 0)) as dom_interactive,
        min(nullif(dom_content_loaded_event_start, 0)) as dom_content_loaded_event_start,
        min(nullif(dom_content_loaded_event_end, 0)) as dom_content_loaded_event_end,
        min(nullif(dom_complete, 0)) as dom_complete,
        min(nullif(load_event_start, 0)) as load_event_start,
        min(nullif(load_event_end, 0)) as load_event_end

    from prep
    group by 1

)

select
    page_view_id,

    case
        when ((redirect_start is not null) and (redirect_end is not null) and (redirect_end >= redirect_start)) then (redirect_end - redirect_start)
        else null
    end as redirect_time_in_ms,

    case
        when ((unload_event_start is not null) and (unload_event_end is not null) and (unload_event_end >= unload_event_start)) then (unload_event_end - unload_event_start)
        else null
    end as unload_time_in_ms,

    case
        when ((fetch_start is not null) and (domain_lookup_start is not null) and (domain_lookup_start >= fetch_start)) then (domain_lookup_start - fetch_start)
        else null
    end as app_cache_time_in_ms,

    case
        when ((domain_lookup_start is not null) and (domain_lookup_end is not null) and (domain_lookup_end >= domain_lookup_start)) then (domain_lookup_end - domain_lookup_start)
        else null
    end as dns_time_in_ms,

    case
        when ((connect_start is not null) and (connect_end is not null) and (connect_end >= connect_start)) then (connect_end - connect_start)
        else null
    end as tcp_time_in_ms,

    case
        when ((request_start is not null) and (response_start is not null) and (response_start >= request_start)) then (response_start - request_start)
        else null
    end as request_time_in_ms,

    case
        when ((response_start is not null) and (response_end is not null) and (response_end >= response_start)) then (response_end - response_start)
        else null
    end as response_time_in_ms,

    case
        when ((dom_loading is not null) and (dom_complete is not null) and (dom_complete >= dom_loading)) then (dom_complete - dom_loading)
        else null
    end as processing_time_in_ms,

    case
        when ((dom_loading is not null) and (dom_interactive is not null) and (dom_interactive >= dom_loading)) then (dom_interactive - dom_loading)
        else null
    end as dom_loading_to_interactive_time_in_ms,

    case
        when ((dom_interactive is not null) and (dom_complete is not null) and (dom_complete >= dom_interactive)) then (dom_complete - dom_interactive)
        else null
    end as dom_interactive_to_complete_time_in_ms,

    case
        when ((load_event_start is not null) and (load_event_end is not null) and (load_event_end >= load_event_start)) then (load_event_end - load_event_start)
        else null
    end as onload_time_in_ms,

    case
        when ((navigation_start is not null) and (load_event_end is not null) and (load_event_end >= navigation_start)) then (load_event_end - navigation_start)
        else null
    end as total_time_in_ms

from rolledup
