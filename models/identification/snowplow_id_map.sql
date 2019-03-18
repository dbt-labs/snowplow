
{{
    config(
        materialized='incremental',
        sort='domain_userid',
        dist='domain_userid',
        unique_key='domain_userid'
    )
}}


{{ snowplow_id_map() }}
