
{{
    config(
        materialized='incremental',
        sort='first_session_start',
        dist='user_snowplow_domain_id',
        sql_where='first_session_start > (select max(first_session_start) from {{ this }})',
        unique_key='user_snowplow_domain_id'
    )
}}


with sessions as (

    select * from {{ ref('snowplow_sessions') }}

),

prep as (

    select
        user_snowplow_domain_id,

        min(session_start) as first_session_start,
        min(session_start_local) as first_session_start_local,
        max(session_end) as last_session_end,
        sum(page_views) as page_views,
        count(*) as sessions,
        sum(time_engaged_in_s) as time_engaged_in_s

    from sessions

    group by 1

),

users as (

    select
        -- user
        a.user_custom_id,
        a.user_snowplow_domain_id,
        a.user_snowplow_crossdomain_id,

        -- first sesssion: time
        b.first_session_start,

        -- derived dimensions
        to_char(b.first_session_start, 'YYYY-MM-DD HH24:MI:SS') as first_session_time,
        to_char(b.first_session_start, 'YYYY-MM-DD HH24:MI') as first_session_minute,
        to_char(b.first_session_start, 'YYYY-MM-DD HH24') as first_session_hour,
        to_char(b.first_session_start, 'YYYY-MM-DD') as first_session_date,
        to_char(date_trunc('week', b.first_session_start), 'YYYY-MM-DD') as first_session_week,
        to_char(b.first_session_start, 'YYYY-MM') as first_session_month,
        to_char(date_trunc('quarter', b.first_session_start), 'YYYY-MM') as first_session_quarter,
        date_part(y, b.first_session_start)::integer as first_session_year,

        -- first session: time in the user's local timezone
        b.first_session_start_local,

        -- derived dimensions
        to_char(b.first_session_start_local, 'YYYY-MM-DD HH24:MI:SS') as first_session_local_time,
        to_char(b.first_session_start_local, 'HH24:MI') as first_session_local_time_of_day,
        date_part(hour, b.first_session_start_local)::integer as first_session_local_hour_of_day,
        trim(to_char(b.first_session_start_local, 'd')) as first_session_local_day_of_week,
        mod(extract(dow from b.first_session_start_local)::integer - 1 + 7, 7) as first_session_local_day_of_week_index,

        -- last session: time
        b.last_session_end,

        -- engagement
        b.page_views,
        b.sessions,
        b.time_engaged_in_s,

        -- first page
        a.first_page_url,
        a.first_page_url_scheme,
        a.first_page_url_host,
        a.first_page_url_port,
        a.first_page_url_path,
        a.first_page_url_query,
        a.first_page_url_fragment,

        a.first_page_title,

        -- referer
        a.referer_url,
        a.referer_url_scheme,
        a.referer_url_host,
        a.referer_url_port,
        a.referer_url_path,
        a.referer_url_query,
        a.referer_url_fragment,

        a.referer_medium,
        a.referer_source,
        a.referer_term,

        -- marketing
        a.marketing_medium,
        a.marketing_source,
        a.marketing_term,
        a.marketing_content,
        a.marketing_campaign,
        a.marketing_click_id,
        a.marketing_network,

        -- application
        a.app_id,

        -- be extra cautious, ensure we only get one record per user_snowplow_domain_id
        row_number() over (partition by a.user_snowplow_domain_id order by b.first_session_start) as dedupe

    from sessions as a
        inner join prep as b on a.user_snowplow_domain_id = b.user_snowplow_domain_id

    where a.session_index = 1
)

select * from users where dedupe = 1
