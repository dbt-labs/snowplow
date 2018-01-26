view: snowplow_users {
  sql_table_name: analytics.snowplow_users ;;

  #User -------------------------------------------------------

  dimension: user_custom_id {
    type: string
    sql: ${TABLE}.user_custom_id ;;
    group_label: "User"
  }

  dimension: user_snowplow_crossdomain_id {
    type: string
    sql: ${TABLE}.user_snowplow_crossdomain_id ;;
    group_label: "User"
  }

  dimension: user_snowplow_domain_id {
    type: string
    sql: ${TABLE}.user_snowplow_domain_id ;;
    group_label: "User"
  }

  dimension: inferred_user_id {
    type: string
    sql: ${TABLE}.inferred_user_id ;;
    group_label: "User"
  }

  dimension: app_id {
    type: string
    sql: ${TABLE}.app_id ;;
    group_label: "User"
  }

  #Metadata -------------------------------------------------------

  dimension: dedupe {
    type: number
    sql: ${TABLE}.dedupe ;;
    group_label: "Metadata"
  }

  dimension: page_views {
    type: number
    sql: ${TABLE}.page_views ;;
    group_label: "Metadata"
  }

  dimension: sessions {
    type: number
    sql: ${TABLE}.sessions ;;
    group_label: "Metadata"
  }

  dimension: time_engaged_in_s {
    type: number
    sql: ${TABLE}.time_engaged_in_s ;;
    group_label: "Metadata"
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
    group_label: "Metadata"
  }

  #First Page -------------------------------------------------------

  dimension: first_page_title {
    type: string
    sql: ${TABLE}.first_page_title ;;
    group_label: "First Page"
  }

  dimension: first_page_url {
    type: string
    sql: ${TABLE}.first_page_url ;;
    group_label: "First Page"
  }

  dimension: first_page_url_fragment {
    type: string
    sql: ${TABLE}.first_page_url_fragment ;;
    group_label: "First Page"
  }

  dimension: first_page_url_host {
    type: string
    sql: ${TABLE}.first_page_url_host ;;
    group_label: "First Page"
  }

  dimension: first_page_url_path {
    type: string
    sql: ${TABLE}.first_page_url_path ;;
    group_label: "First Page"
  }

  dimension: first_page_url_port {
    type: number
    sql: ${TABLE}.first_page_url_port ;;
    group_label: "First Page"
  }

  dimension: first_page_url_query {
    type: string
    sql: ${TABLE}.first_page_url_query ;;
    group_label: "First Page"
  }

  dimension: first_page_url_scheme {
    type: string
    sql: ${TABLE}.first_page_url_scheme ;;
    group_label: "First Page"
  }

  #First Session -------------------------------------------------------

  dimension: first_session_date {
    type: string
    sql: ${TABLE}.first_session_date ;;
    group_label: "First Session"
  }

  dimension: first_session_hour {
    type: string
    sql: ${TABLE}.first_session_hour ;;
    group_label: "First Session"
  }

  dimension: first_session_local_day_of_week {
    type: string
    sql: ${TABLE}.first_session_local_day_of_week ;;
    group_label: "First Session"
  }

  dimension: first_session_local_day_of_week_index {
    type: number
    sql: ${TABLE}.first_session_local_day_of_week_index ;;
    group_label: "First Session"
  }

  dimension: first_session_local_hour_of_day {
    type: number
    sql: ${TABLE}.first_session_local_hour_of_day ;;
    group_label: "First Session"
  }

  dimension: first_session_local_time {
    type: string
    sql: ${TABLE}.first_session_local_time ;;
    group_label: "First Session"
  }

  dimension: first_session_local_time_of_day {
    type: string
    sql: ${TABLE}.first_session_local_time_of_day ;;
    group_label: "First Session"
  }

  dimension: first_session_minute {
    type: string
    sql: ${TABLE}.first_session_minute ;;
    group_label: "First Session"
  }

  dimension: first_session_month {
    type: string
    sql: ${TABLE}.first_session_month ;;
    group_label: "First Session"
  }

  dimension: first_session_quarter {
    type: string
    sql: ${TABLE}.first_session_quarter ;;
    group_label: "First Session"
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
    group_label: "First Session"
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
    group_label: "First Session"
  }

  dimension: first_session_time {
    type: string
    sql: ${TABLE}.first_session_time ;;
    group_label: "First Session"
  }

  dimension: first_session_week {
    type: string
    sql: ${TABLE}.first_session_week ;;
    group_label: "First Session"
  }

  dimension: first_session_year {
    type: number
    sql: ${TABLE}.first_session_year ;;
    group_label: "First Session"
  }

  #Marketing -------------------------------------------------------

  dimension: marketing_campaign {
    type: string
    sql: ${TABLE}.marketing_campaign ;;
    group_label: "Marketing"
  }

  dimension: marketing_click_id {
    type: string
    sql: ${TABLE}.marketing_click_id ;;
    group_label: "Marketing"
  }

  dimension: marketing_content {
    type: string
    sql: ${TABLE}.marketing_content ;;
    group_label: "Marketing"
  }

  dimension: marketing_medium {
    type: string
    sql: ${TABLE}.marketing_medium ;;
    group_label: "Marketing"
  }

  dimension: marketing_network {
    type: string
    sql: ${TABLE}.marketing_network ;;
    group_label: "Marketing"
  }

  dimension: marketing_source {
    type: string
    sql: ${TABLE}.marketing_source ;;
    group_label: "Marketing"
  }

  dimension: marketing_term {
    type: string
    sql: ${TABLE}.marketing_term ;;
    group_label: "Marketing"
  }

  #Referer -------------------------------------------------------

  dimension: referer_medium {
    type: string
    sql: ${TABLE}.referer_medium ;;
    group_label: "Referer"
  }

  dimension: referer_source {
    type: string
    sql: ${TABLE}.referer_source ;;
    group_label: "Referer"
  }

  dimension: referer_term {
    type: string
    sql: ${TABLE}.referer_term ;;
    group_label: "Referer"
  }

  dimension: referer_url {
    type: string
    sql: ${TABLE}.referer_url ;;
    group_label: "Referer"
  }

  dimension: referer_url_fragment {
    type: string
    sql: ${TABLE}.referer_url_fragment ;;
    group_label: "Referer"
  }

  dimension: referer_url_host {
    type: string
    sql: ${TABLE}.referer_url_host ;;
    group_label: "Referer"
  }

  dimension: referer_url_path {
    type: string
    sql: ${TABLE}.referer_url_path ;;
    group_label: "Referer"
  }

  dimension: referer_url_port {
    type: number
    sql: ${TABLE}.referer_url_port ;;
    group_label: "Referer"
  }

  dimension: referer_url_query {
    type: string
    sql: ${TABLE}.referer_url_query ;;
    group_label: "Referer"
  }

  dimension: referer_url_scheme {
    type: string
    sql: ${TABLE}.referer_url_scheme ;;
    group_label: "Referer"
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
