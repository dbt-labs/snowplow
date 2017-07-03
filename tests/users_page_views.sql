with users as (
    select inferred_user_id, page_views
    from {{ref('snowplow_users')}}
)

,

sessions as (
    select inferred_user_id, sum(page_views) as page_views
    from {{ref('snowplow_sessions')}}
    group by 1
)
,

calc as (
    select inferred_user_id,
    users.page_views as users_page_views,
    sessions.page_views as sessions_page_views
    from users
    full join sessions USING (inferred_user_id)
)

select * from calc where users_page_views!=sessions_page_views
