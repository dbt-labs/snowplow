{{ config(
    enabled=(var('snowplow:context:useragent') and is_adapter('default'))
) }}

select * from {{ var('snowplow:context:useragent') }}
