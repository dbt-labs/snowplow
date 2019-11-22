

{% macro snowplow_web_events_tmp() %}

    {{ adapter_macro('snowplow.snowplow_web_events_tmp') }}

{% endmacro %}

{% macro default__snowplow_web_events_tmp() %}

with relevant_events as (

    select * from {{ ref('snowplow_base_events') }}
    where event_name in ('page_view', 'page_ping')
    {% if is_incremental() %}
    
        {% set ts_field = 'collector_tstamp' if this.identifier == 'snowplow_web_events' else 'max_tstamp' %}
        
        {% set start_ts = get_most_recent_record(this, ts_field, '2001-01-01') %}
    
        and {{ var('snowplow:partition_col').name }} >= 
            date_trunc('{{ var("snowplow:partition_col").precision }}', '{{start_ts}}'::timestamp)
    {% endif %}

),

{% if var('snowplow:context:web_page', False) %}
{# Grab the page_view_id from the separate context table #}

web_page_context as (

    select * from {{ ref('snowplow_web_page_context') }}

),

prep as (

    select

        ev.*,
        wp.page_view_id

    from relevant_events as ev
        inner join web_page_context as wp on ev.event_id = wp.root_id
        
)

select * from prep

{% else %}
{# page_view_id on canonical event table #}

    {% if target.type == 'snowflake' %}
    {# Unnest the page_view_id on Snowflake #}

    prep as (
        
        select
        
            relevant_events.*,
            context.value:data.id::varchar as page_view_id
            
        from relevant_events, lateral flatten (input => parse_json(contexts):data) context
        where context.value:schema ilike '%/web_page/%'
        
    ),

    {% else %}
    {# Assume the page_view_id is already present #}
        
    prep as (

        select * from relevant_events
        
    ),

    {% endif %}

-- perform page_view_id deduplication directly within events

duplicated as (

    select
    
        event_id

    from prep
    group by 1
    having count(distinct page_view_id) > 1

)
    
select * from prep
where event_id not in (select event_id from duplicated)

{% endif %}

{% endmacro %}