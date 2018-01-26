view: snowplow_page_views {
  sql_table_name: analytics.snowplow_page_views ;;

  #App -------------------------------------------------------

  dimension: app_cache_time_in_ms {
    type: number
    sql: ${TABLE}.app_cache_time_in_ms ;;
    group_label: "App"
  }

  dimension: app_id {
    type: string
    sql: ${TABLE}.app_id ;;
    group_label: "App"
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

  dimension: browser_window_height {
    type: number
    sql: ${TABLE}.browser_window_height ;;
    group_label: "Browser"
  }

  dimension: browser_window_width {
    type: number
    sql: ${TABLE}.browser_window_width ;;
    group_label: "Browser"
  }

 #Device -------------------------------------------------------

  dimension: device {
    type: string
    sql: ${TABLE}.device ;;
    group_label: "Device"
  }

  dimension: device_is_mobile {
    type: yesno
    sql: ${TABLE}.device_is_mobile ;;
    group_label: "Device"
  }

  dimension: device_type {
    type: string
    sql: ${TABLE}.device_type ;;
    group_label: "Device"
  }

  #Load Time -------------------------------------------------------

  dimension: dns_time_in_ms {
    type: number
    sql: ${TABLE}.dns_time_in_ms ;;
    group_label: "Load Time"
  }

  dimension: dom_interactive_to_complete_time_in_ms {
    type: number
    sql: ${TABLE}.dom_interactive_to_complete_time_in_ms ;;
    group_label: "Load Time"
  }

  dimension: dom_loading_to_interactive_time_in_ms {
    type: number
    sql: ${TABLE}.dom_loading_to_interactive_time_in_ms ;;
    group_label: "Load Time"
  }

  dimension: onload_time_in_ms {
    type: number
    sql: ${TABLE}.onload_time_in_ms ;;
    group_label: "Timestamps"
  }

  dimension: processing_time_in_ms {
    type: number
    sql: ${TABLE}.processing_time_in_ms ;;
  }

  dimension: redirect_time_in_ms {
    type: number
    sql: ${TABLE}.redirect_time_in_ms ;;
  }

  dimension: tcp_time_in_ms {
    type: number
    sql: ${TABLE}.tcp_time_in_ms ;;
  }

  dimension: time_engaged_in_s {
    type: number
    sql: ${TABLE}.time_engaged_in_s ;;
  }

  dimension: time_engaged_in_s_tier {
    type: string
    sql: ${TABLE}.time_engaged_in_s_tier ;;
  }

  dimension: total_time_in_ms {
    type: number
    sql: ${TABLE}.total_time_in_ms ;;
  }

  dimension: unload_time_in_ms {
    type: number
    sql: ${TABLE}.unload_time_in_ms ;;
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
    type: zipcode
    sql: ${TABLE}.geo_zipcode ;;
    group_label: "Geo"
  }

  dimension: geo_latlong {
    type: location
    sql_latitude: ${TABLE}.geo_latitude ;;
    sql_longitude: ${TABLE}.geo_longitude ;;
    group_label: "Geo"
  }

  #Scrolling -------------------------------------------------------

  dimension: horizontal_percentage_scrolled {
    type: number
    sql: ${TABLE}.horizontal_percentage_scrolled ;;
    group_label: "Scrolling"
  }

  dimension: horizontal_pixels_scrolled {
    type: number
    sql: ${TABLE}.horizontal_pixels_scrolled ;;
    group_label: "Scrolling"
  }

  dimension: vertical_percentage_scrolled {
    type: number
    sql: ${TABLE}.vertical_percentage_scrolled ;;
  }

  dimension: vertical_percentage_scrolled_tier {
    type: string
    sql: ${TABLE}.vertical_percentage_scrolled_tier ;;
  }

  dimension: vertical_pixels_scrolled {
    type: number
    sql: ${TABLE}.vertical_pixels_scrolled ;;
  }

  #IP -------------------------------------------------------

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

  #Timestamps -------------------------------------------------------

  dimension_group: max_tstamp {
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
    sql: ${TABLE}.max_tstamp ;;
    group_label: "Timestamps"
  }

  dimension_group: min_tstamp {
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
    sql: ${TABLE}.min_tstamp ;;
    group_label: "Timestamps"
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

  #Page -------------------------------------------------------

  dimension: page_height {
    type: number
    sql: ${TABLE}.page_height ;;
    group_label: "Page"
  }

  dimension: page_width {
    type: number
    sql: ${TABLE}.page_width ;;
    group_label: "Page"
  }

  dimension: page_title {
    type: string
    sql: ${TABLE}.page_title ;;
    group_label: "Page"
  }

  dimension: page_url {
    type: string
    sql: ${TABLE}.page_url ;;
    group_label: "Page"
  }

  dimension: page_url_fragment {
    type: string
    sql: ${TABLE}.page_url_fragment ;;
    group_label: "Page"
  }

  dimension: page_url_host {
    type: string
    sql: ${TABLE}.page_url_host ;;
    group_label: "Page"
  }

  dimension: page_url_path {
    type: string
    sql: ${TABLE}.page_url_path ;;
    group_label: "Page"
  }

  dimension: page_url_port {
    type: number
    sql: ${TABLE}.page_url_port ;;
    group_label: "Page"
  }

  dimension: page_url_query {
    type: string
    sql: ${TABLE}.page_url_query ;;
    group_label: "Page"
  }

  dimension: page_url_scheme {
    type: string
    sql: ${TABLE}.page_url_scheme ;;
    group_label: "Page"
  }

  #Page View  -------------------------------------------------------

  dimension: page_view_date {
    type: string
    sql: ${TABLE}.page_view_date ;;
    group_label: "Page View"
  }

  dimension_group: page_view_end {
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
    sql: ${TABLE}.page_view_end ;;
    group_label: "Page View"
  }

  dimension_group: page_view_end_local {
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
    sql: ${TABLE}.page_view_end_local ;;
    group_label: "Page View"
  }

  dimension: page_view_hour {
    type: string
    sql: ${TABLE}.page_view_hour ;;
    group_label: "Page View"
  }

  dimension: page_view_id {
    type: string
    sql: ${TABLE}.page_view_id ;;
    group_label: "Page View"
  }

  dimension: page_view_in_session_index {
    type: number
    sql: ${TABLE}.page_view_in_session_index ;;
    group_label: "Page View"
  }

  dimension: page_view_index {
    type: number
    sql: ${TABLE}.page_view_index ;;
    group_label: "Page View"
  }

  dimension: page_view_local_day_of_week {
    type: string
    sql: ${TABLE}.page_view_local_day_of_week ;;
    group_label: "Page View"
  }

  dimension: page_view_local_day_of_week_index {
    type: number
    sql: ${TABLE}.page_view_local_day_of_week_index ;;
    group_label: "Page View"
  }

  dimension: page_view_local_hour_of_day {
    type: number
    sql: ${TABLE}.page_view_local_hour_of_day ;;
    group_label: "Page View"
  }

  dimension: page_view_local_time {
    type: string
    sql: ${TABLE}.page_view_local_time ;;
    group_label: "Page View"
  }

  dimension: page_view_local_time_of_day {
    type: string
    sql: ${TABLE}.page_view_local_time_of_day ;;
    group_label: "Page View"
  }

  dimension: page_view_minute {
    type: string
    sql: ${TABLE}.page_view_minute ;;
    group_label: "Page View"
  }

  dimension: page_view_month {
    type: string
    sql: ${TABLE}.page_view_month ;;
    group_label: "Page View"
  }

  dimension: page_view_quarter {
    type: string
    sql: ${TABLE}.page_view_quarter ;;
    group_label: "Page View"
  }

  dimension_group: page_view_start {
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
    sql: ${TABLE}.page_view_start ;;
    group_label: "Page View"
  }

  dimension_group: page_view_start_local {
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
    sql: ${TABLE}.page_view_start_local ;;
    group_label: "Page View"
  }

  dimension: page_view_time {
    type: string
    sql: ${TABLE}.page_view_time ;;
    group_label: "Page View"
  }

  dimension: page_view_week {
    type: string
    sql: ${TABLE}.page_view_week ;;
    group_label: "Page View"
  }

  dimension: page_view_year {
    type: number
    sql: ${TABLE}.page_view_year ;;
    group_label: "Page View"
  }

  #Referer  -------------------------------------------------------

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

  dimension: request_time_in_ms {
    type: number
    sql: ${TABLE}.request_time_in_ms ;;
    group_label: "Referer"
  }

  dimension: response_time_in_ms {
    type: number
    sql: ${TABLE}.response_time_in_ms ;;
    group_label: "Referer"
  }

  #Session  -------------------------------------------------------

  dimension: session_id {
    type: string
    sql: ${TABLE}.session_id ;;
    group_label: "Session"
  }

  dimension: session_index {
    type: number
    sql: ${TABLE}.session_index ;;
    group_label: "Session"
  }

  #User  -------------------------------------------------------

  dimension: user_bounced {
    type: yesno
    sql: ${TABLE}.user_bounced ;;
    group_label: "User"
  }

  dimension: user_custom_id {
    type: string
    sql: ${TABLE}.user_custom_id ;;
    group_label: "User"
  }

  dimension: user_engaged {
    type: yesno
    sql: ${TABLE}.user_engaged ;;
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

  # Measures

  measure: count {
    type: count
    drill_fields: [geo_region_name, browser_name, os_name]
  }
}
