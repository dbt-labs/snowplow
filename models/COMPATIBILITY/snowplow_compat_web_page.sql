
{{ config(materialized='view') }}

select event_id as root_id, id from snowplow.web_page
