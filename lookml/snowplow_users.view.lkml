view: snowplow_users {
  sql_table_name: analytics.snowplow_users ;;

  dimension: app_id {
    type: string
    sql: ${TABLE}.app_id ;;
  }

  dimension: dedupe {
    type: number
    sql: ${TABLE}.dedupe ;;
  }

  dimension: first_page_title {
    type: string
    sql: ${TABLE}.first_page_title ;;
  }

  dimension: first_page_url {
    type: string
    sql: ${TABLE}.first_page_url ;;
  }

  dimension: first_page_url_fragment {
    type: string
    sql: ${TABLE}.first_page_url_fragment ;;
  }

  dimension: first_page_url_host {
    type: string
    sql: ${TABLE}.first_page_url_host ;;
  }

  dimension: first_page_url_path {
    type: string
    sql: ${TABLE}.first_page_url_path ;;
  }

  dimension: first_page_url_port {
    type: number
    sql: ${TABLE}.first_page_url_port ;;
  }

  dimension: first_page_url_query {
    type: string
    sql: ${TABLE}.first_page_url_query ;;
  }

  dimension: first_page_url_scheme {
    type: string
    sql: ${TABLE}.first_page_url_scheme ;;
  }

  dimension: first_session_date {
    type: string
    sql: ${TABLE}.first_session_date ;;
  }

  dimension: first_session_hour {
    type: string
    sql: ${TABLE}.first_session_hour ;;
  }

  dimension: first_session_local_day_of_week {
    type: string
    sql: ${TABLE}.first_session_local_day_of_week ;;
  }

  dimension: first_session_local_day_of_week_index {
    type: number
    sql: ${TABLE}.first_session_local_day_of_week_index ;;
  }

  dimension: first_session_local_hour_of_day {
    type: number
    sql: ${TABLE}.first_session_local_hour_of_day ;;
  }

  dimension: first_session_local_time {
    type: string
    sql: ${TABLE}.first_session_local_time ;;
  }

  dimension: first_session_local_time_of_day {
    type: string
    sql: ${TABLE}.first_session_local_time_of_day ;;
  }

  dimension: first_session_minute {
    type: string
    sql: ${TABLE}.first_session_minute ;;
  }

  dimension: first_session_month {
    type: string
    sql: ${TABLE}.first_session_month ;;
  }

  dimension: first_session_quarter {
    type: string
    sql: ${TABLE}.first_session_quarter ;;
  }

  dimension_group: first_session_start {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.first_session_start ;;
  }

  dimension_group: first_session_start_local {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.first_session_start_local ;;
  }

  dimension: first_session_time {
    type: string
    sql: ${TABLE}.first_session_time ;;
  }

  dimension: first_session_week {
    type: string
    sql: ${TABLE}.first_session_week ;;
  }

  dimension: first_session_year {
    type: number
    sql: ${TABLE}.first_session_year ;;
  }

  dimension: inferred_user_id {
    type: string
    sql: ${TABLE}.inferred_user_id ;;
  }

  dimension_group: last_session_end {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.last_session_end ;;
  }

  dimension: marketing_campaign {
    type: string
    sql: ${TABLE}.marketing_campaign ;;
  }

  dimension: marketing_click_id {
    type: string
    sql: ${TABLE}.marketing_click_id ;;
  }

  dimension: marketing_content {
    type: string
    sql: ${TABLE}.marketing_content ;;
  }

  dimension: marketing_medium {
    type: string
    sql: ${TABLE}.marketing_medium ;;
  }

  dimension: marketing_network {
    type: string
    sql: ${TABLE}.marketing_network ;;
  }

  dimension: marketing_source {
    type: string
    sql: ${TABLE}.marketing_source ;;
  }

  dimension: marketing_term {
    type: string
    sql: ${TABLE}.marketing_term ;;
  }

  dimension: page_views {
    type: number
    sql: ${TABLE}.page_views ;;
  }

  dimension: referer_medium {
    type: string
    sql: ${TABLE}.referer_medium ;;
  }

  dimension: referer_source {
    type: string
    sql: ${TABLE}.referer_source ;;
  }

  dimension: referer_term {
    type: string
    sql: ${TABLE}.referer_term ;;
  }

  dimension: referer_url {
    type: string
    sql: ${TABLE}.referer_url ;;
  }

  dimension: referer_url_fragment {
    type: string
    sql: ${TABLE}.referer_url_fragment ;;
  }

  dimension: referer_url_host {
    type: string
    sql: ${TABLE}.referer_url_host ;;
  }

  dimension: referer_url_path {
    type: string
    sql: ${TABLE}.referer_url_path ;;
  }

  dimension: referer_url_port {
    type: number
    sql: ${TABLE}.referer_url_port ;;
  }

  dimension: referer_url_query {
    type: string
    sql: ${TABLE}.referer_url_query ;;
  }

  dimension: referer_url_scheme {
    type: string
    sql: ${TABLE}.referer_url_scheme ;;
  }

  dimension: sessions {
    type: number
    sql: ${TABLE}.sessions ;;
  }

  dimension: time_engaged_in_s {
    type: number
    sql: ${TABLE}.time_engaged_in_s ;;
  }

  dimension: user_custom_id {
    type: string
    sql: ${TABLE}.user_custom_id ;;
  }

  dimension: user_snowplow_crossdomain_id {
    type: string
    sql: ${TABLE}.user_snowplow_crossdomain_id ;;
  }

  dimension: user_snowplow_domain_id {
    type: string
    sql: ${TABLE}.user_snowplow_domain_id ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
