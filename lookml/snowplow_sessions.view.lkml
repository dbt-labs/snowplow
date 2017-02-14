view: snowplow_sessions {
  sql_table_name: analytics.snowplow_sessions ;;

  #Session identifying information
  dimension: session_id {
    type: string
    sql: ${TABLE}.session_id ;;
  }

  dimension: session_index {
    type: number
    sql: ${TABLE}.session_index ;;
  }

  dimension: app_id {
    type: string
    sql: ${TABLE}.app_id ;;
  }


  #User identifying information

  dimension: inferred_user_id {
    type: string
    sql: ${TABLE}.inferred_user_id ;;
    group_label: "User IDs"
  }

  dimension: user_custom_id {
    type: string
    sql: ${TABLE}.user_custom_id ;;
    group_label: "User IDs"
  }

  dimension: user_snowplow_domain_id {
    type: string
    sql: ${TABLE}.user_snowplow_domain_id ;;
    group_label: "User IDs"
  }

  dimension: user_snowplow_crossdomain_id {
    type: string
    sql: ${TABLE}.user_snowplow_crossdomain_id ;;
    group_label: "User IDs"
  }


  #Timestamps

  dimension_group: session_end {
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
    sql: ${TABLE}.session_end ;;
  }

  dimension_group: session_end_local {
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
    sql: ${TABLE}.session_end_local ;;
  }

  dimension_group: session_start {
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
    sql: ${TABLE}.session_start ;;
  }

  dimension_group: session_start_local {
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
    sql: ${TABLE}.session_start_local ;;
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

  #Geo -------------------------------------------------------

  dimension: geo_city {
    type: string
    sql: ${TABLE}.geo_city ;;
    group_label: "Geo"
  }

  dimension: geo_country {
    type: string
    sql: ${TABLE}.geo_country ;;
    group_label: "Geo"
  }

  dimension: geo_latitude {
    type: string
    sql: ${TABLE}.geo_latitude ;;
    group_label: "Geo"
  }

  dimension: geo_longitude {
    type: string
    sql: ${TABLE}.geo_longitude ;;
    group_label: "Geo"
  }

  dimension: geo_region {
    type: string
    sql: ${TABLE}.geo_region ;;
    group_label: "Geo"
  }

  dimension: geo_region_name {
    type: string
    sql: ${TABLE}.geo_region_name ;;
    group_label: "Geo"
  }

  dimension: geo_timezone {
    type: string
    sql: ${TABLE}.geo_timezone ;;
    group_label: "Geo"
  }

  dimension: geo_zipcode {
    type: string
    sql: ${TABLE}.geo_zipcode ;;
    group_label: "Geo"
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



#Browser -------------------------------------------------------

  dimension: browser {
    type: string
    sql: ${TABLE}.browser ;;
    group_label: "Browser"
  }

  dimension: browser_build_version {
    type: string
    sql: ${TABLE}.browser_build_version ;;
    group_label: "Browser"
  }

  dimension: browser_engine {
    type: string
    sql: ${TABLE}.browser_engine ;;
    group_label: "Browser"
  }

  dimension: browser_language {
    type: string
    sql: ${TABLE}.browser_language ;;
    group_label: "Browser"
  }

  dimension: browser_major_version {
    type: string
    sql: ${TABLE}.browser_major_version ;;
    group_label: "Browser"
  }

  dimension: browser_minor_version {
    type: string
    sql: ${TABLE}.browser_minor_version ;;
    group_label: "Browser"
  }

  dimension: browser_name {
    type: string
    sql: ${TABLE}.browser_name ;;
    group_label: "Browser"
  }

  dimension: device {
    type: string
    sql: ${TABLE}.device ;;
  }

  dimension: device_is_mobile {
    type: yesno
    sql: ${TABLE}.device_is_mobile ;;
  }

  dimension: device_type {
    type: string
    sql: ${TABLE}.device_type ;;
  }

  dimension: engaged_page_views {
    type: number
    sql: ${TABLE}.engaged_page_views ;;
  }

#OS -------------------------------------------------------

  dimension: os {
    type: string
    sql: ${TABLE}.os ;;
    group_label: "OS"
  }

  dimension: os_build_version {
    type: string
    sql: ${TABLE}.os_build_version ;;
    group_label: "OS"
  }

  dimension: os_major_version {
    type: string
    sql: ${TABLE}.os_major_version ;;
    group_label: "OS"
  }

  dimension: os_manufacturer {
    type: string
    sql: ${TABLE}.os_manufacturer ;;
    group_label: "OS"
  }

  dimension: os_minor_version {
    type: string
    sql: ${TABLE}.os_minor_version ;;
    group_label: "OS"
  }

  dimension: os_name {
    type: string
    sql: ${TABLE}.os_name ;;
    group_label: "OS"
  }

  dimension: os_timezone {
    type: string
    sql: ${TABLE}.os_timezone ;;
    group_label: "OS"
  }



  # IP -------------------------------------------------------

  dimension: ip_address {
    type: string
    sql: ${TABLE}.ip_address ;;
    group_label: "IP"
  }

  dimension: ip_domain {
    type: string
    sql: ${TABLE}.ip_domain ;;
    group_label: "IP"
  }

  dimension: ip_isp {
    type: string
    sql: ${TABLE}.ip_isp ;;
    group_label: "IP"
  }

  dimension: ip_net_speed {
    type: string
    sql: ${TABLE}.ip_net_speed ;;
    group_label: "IP"
  }

  dimension: ip_organization {
    type: string
    sql: ${TABLE}.ip_organization ;;
    group_label: "IP"
  }



  dimension: time_engaged_in_s {
    label: "Time Engaged (seconds)"
    type: number
    sql: ${TABLE}.time_engaged_in_s ;;
  }

  dimension: time_engaged_in_s_tier {
    label: "Time Engaged Tier"
    type: string
    sql: ${TABLE}.time_engaged_in_s_tier ;;
  }

  dimension: user_bounced {
    label: "Bounced?"
    type: yesno
    sql: ${TABLE}.user_bounced ;;
  }

  dimension: user_engaged {
    label: "Engaged?"
    type: yesno
    sql: ${TABLE}.user_engaged ;;
  }

  dimension: bounced_page_views {
    type: number
    sql: ${TABLE}.bounced_page_views ;;
  }

  dimension: new_vs_returning {
    type: string
    sql:
      case
        when ${session_index} = 1 then 'new'
        else 'returning'
      end ;;
  }


  # Measures

  measure: sessions {
    type: count
    drill_fields: [geo_region_name, browser_name, os_name]
    value_format_name: decimal_0
  }

  measure: page_views {
    type: sum
    sql: ${TABLE}.page_views ;;
    value_format_name: decimal_0
  }

  measure: distinct_users {
    label: "Distinct Users"
    type: count_distinct
    sql: ${inferred_user_id} ;;
    value_format_name: decimal_0
  }

  measure: average_time_engaged_in_s {
    label: "Average Time Engaged (seconds)"
    type: average
    sql: ${time_engaged_in_s} ;;
    value_format_name: decimal_0
  }

  measure: sessions_from_new_visitors {
    type: count
    filters: {
      field: new_vs_returning
      value: "new"
    }
    value_format_name: decimal_0
  }

  measure: sessions_from_returning_visitors {
    type: count
    filters: {
      field: new_vs_returning
      value: "returning"
    }
    value_format_name: decimal_0
  }

  measure: percent_new_visitors {
    type: number
    sql: ${sessions_from_new_visitors}::float / nullif(${sessions}, 0) ;;
    value_format_name: percent_1
  }

  measure: percent_returning_visitors {
    type: number
    sql: ${sessions_from_returning_visitors}::float / nullif(${sessions}, 0) ;;
    value_format_name: percent_1
  }

  measure: bounced_sessions {
    type: count
    filters: {
      field: user_bounced
      value: "yes"
    }
    value_format_name: decimal_0
  }

  measure: bounce_rate {
    type: number
    sql: ${bounced_sessions}::float / nullif(${sessions}, 0) ;;
    value_format_name: percent_1
  }

  measure: sessions_per_user {
    type: number
    sql: ${sessions}::float / nullif(${distinct_users}, 0) ;;
    value_format_name: decimal_2
  }


  set: count_drill {
    fields: [
      inferred_user_id,
      session_index,
      session_start_date,
      session_end_date,
      time_engaged_in_s
    ]
  }
}
