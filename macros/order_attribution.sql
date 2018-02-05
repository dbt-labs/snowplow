{% macro order_attribution(orders_xf,order_id,order_created_on) -%}

/* ----- SHOPPING LIST -----

1.  Need to write a macro for case/when statements that works in RS/flake
    and also in BQ syntax (https://cloud.google.com/dataprep/docs/html/IF-Function_57344759)

2.  date_trunc + datediff functions (it's just the opposite order in
    BQ 'datetime_trunc' and 'datetime_diff')

3.  Window functions: After initial research, I *think* these basic functions
    (rank, count, row_number) all work across databases, but needs a lot of testing.

*/


with sessions as (

  select *
  from {{ref('snowplow_sessions_xf')}}

),

orders_xf as (

  select {{ order_id }} as order_id,
         {{ order_created_on }} as created_on
  from {{ref({{ orders_table }})}}

),

joined as (

  select *,
  from orders_xf
  join sessions on orders_xf.order_id = sessions.user_custom_id
    where sessions.session_start < orders_xf.created_on
    and {{ dbt_utils.dateadd('day', 28, date_trunc('day', sessions.session_start)) }} >=
        date_trunc('day', orders_xf.created_on)

),

ranked as (

    select *,

        case when user_custom_id is not null
            then rank() over (partition by order_id order by session_start)
            else null end as attribution_number,

        case when user_custom_id is not null
            then count(*) over (partition by order_id order by session_start
            rows between unbounded preceding and unbounded following)
            else null end as total_attribution_count,

        case when user_custom_id is not null
            then rank() over (partition by order_id, channel order by session_start)
            else null end as attribution_channel_number,

        case when user_custom_id is not null
            then count(*) over (partition by order_id, channel order by session_start
            rows between unbounded preceding and unbounded following)
            else null end as channel_attribution_count,

        case when user_custom_id is not null
            then row_number() over (partition by order_id
                    order by session_start)
            else null end as order_session_number,

        case when user_custom_id is not null
            then count(*) over (partition by order_id)
            else null end as order_total_sessions,

        lag(session_start) over (partition by order_id order by session_start)
            as previous_session_start

    from joined

),

base as (

    select

        {{ dbt_utils.surrogate_key('order_id','coalesce(order_session_number,''))') }}
            as attribution_id,

        ranked.*,

        case
            when order_total_sessions = 1 then 1.0
            when order_total_sessions = 2 then 0.5
            when order_session_number = 1 then 0.4
            when order_session_number = order_total_sessions then 0.4
            else 0.2 / (order_total_sessions - 2)
        end as forty_twenty_forty_attribution_points,

        case
            when order_session_number = 1 then 1.0
            else 0.0
        end as first_click_attribution_points,

        case
            when order_session_number = order_total_sessions then 1.0
            else 0.0
        end as last_click_attribution_points,

        1.0 / order_total_sessions as linear_attribution_points,

        date_diff('hour', previous_session_start, session_start) as hours_from_previous_session,

        count(*) over (partition by order_id
            rows between unbounded preceding and unbounded following) as count_touches

    from ranked

)

select * from base

{%- endmacro %}
