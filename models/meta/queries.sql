
{{
    config({
        "distkey" : "component",
        "sortkey" : "tstamp",
        "post-hook": "INSERT INTO {{ this }} (SELECT 'main', 'start', {{ var('now') }} )",
        "materialized" : "incremental",
        "sql_where"    : "FALSE"
    })
}}

select
''::varchar(255) as component,
''::varchar(255) as step,
'2016-01-01'::timestamp as tstamp,
'2016-01-01'::timestamp as run_started_at
limit 0
