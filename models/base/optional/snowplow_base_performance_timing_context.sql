{{ config(
    enabled=(var('snowplow:context:performance_timing') and is_adapter('default'))
) }}

select * from {{ var('snowplow:context:performance_timing') }}
