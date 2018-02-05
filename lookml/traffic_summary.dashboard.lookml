- dashboard: traffic_summary
  title: Traffic Summary
  layout: grid
  width: 800
  rows:
    - elements: [last_week_sessions, last_week_uniques, last_week_bounce_rate]
      height: 200
    - elements: [sessions]
      height: 300
    - elements: [time_on_site, new_vs_returning_sessions]
      height: 300
    - elements: [sessions_by_traffic_source, sessions_by_device]
      height: 300
    - elements: [sessions_by_country, sessions_by_landing_page_title]
      height: 300

  elements:

    #Last Week Sessions -------------------------------------------------------
  - name: last_week_sessions
    title: Last Week Sessions
    model: snowplow_web_analytics
    explore: snowplow_sessions
    type: single_value
    fields:
    - snowplow_sessions.session_start_week
    - snowplow_sessions.sessions
    fill_fields:
    - snowplow_sessions.session_start_week
    filters:
      snowplow_sessions.session_start_week: before this week
    sorts:
    - snowplow_sessions.session_start_week desc
    limit: 500
    column_limit: 50
    dynamic_fields:
    - table_calculation: last_week_sessions
      label: last_week_sessions
      expression: offset(${snowplow_sessions.sessions}, 1)
      value_format:
      value_format_name: decimal_0
    - table_calculation: wow_change
      label: wow_change
      expression: "(${snowplow_sessions.sessions} - ${last_week_sessions}) / ${last_week_sessions}"
      value_format:
      value_format_name: percent_0
    query_timezone: America/New_York
    custom_color_enabled: false
    custom_color: forestgreen
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    stacking: ''
    show_value_labels: false
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: true
    limit_displayed_rows: false
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_scale_mode: linear
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#1C2260"
    series_types: {}
    hidden_fields:
    - last_week_sessions
    comparison_label: week-over-week
    listen:
      new_vs_returning: snowplow_sessions.new_vs_returning
      device: snowplow_sessions.device_type
      traffic_source: snowplow_sessions.referer_source
    row: 0
    col: 0
    width: 6
    height: 4

    #Last Week Uniques -------------------------------------------------------
  - name: last_week_uniques
    title: Last Week Uniques
    model: snowplow_web_analytics
    explore: snowplow_sessions
    type: single_value
    fields:
    - snowplow_sessions.session_start_week
    - snowplow_sessions.distinct_users
    fill_fields:
    - snowplow_sessions.session_start_week
    filters:
      snowplow_sessions.session_start_week: before this week
    sorts:
    - snowplow_sessions.session_start_week desc
    limit: 500
    column_limit: 50
    dynamic_fields:
    - table_calculation: last_week
      label: last_week
      expression: offset(${snowplow_sessions.distinct_users}, 1)
      value_format:
      value_format_name: decimal_0
    - table_calculation: wow_change
      label: wow_change
      expression: "(${snowplow_sessions.distinct_users} - ${last_week}) / ${last_week}"
      value_format:
      value_format_name: percent_0
    query_timezone: America/New_York
    custom_color_enabled: false
    custom_color: forestgreen
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    stacking: ''
    show_value_labels: false
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: true
    limit_displayed_rows: false
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_scale_mode: linear
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#1C2260"
    series_types: {}
    hidden_fields:
    - last_week_sessions
    - last_week
    comparison_label: week-over-week
    listen:
      new_vs_returning: snowplow_sessions.new_vs_returning
      device: snowplow_sessions.device_type
      traffic_source: snowplow_sessions.referer_source
    row: 0
    col: 6
    width: 6
    height: 4

    #Last Week Uniques -------------------------------------------------------
  - name: last_week_bounce_rate
    title: Last Week Bounce Rate
    model: snowplow_web_analytics
    explore: snowplow_sessions
    type: single_value
    fields:
    - snowplow_sessions.session_start_week
    - snowplow_sessions.bounce_rate
    fill_fields:
    - snowplow_sessions.session_start_week
    filters:
      snowplow_sessions.session_start_week: before this week
    sorts:
    - snowplow_sessions.session_start_week desc
    limit: 500
    column_limit: 50
    dynamic_fields:
    - table_calculation: last_week
      label: last_week
      expression: offset(${snowplow_sessions.bounce_rate}, 1)
      value_format:
      value_format_name: percent_2
    - table_calculation: wow_change
      label: wow_change
      expression: "(${snowplow_sessions.bounce_rate} - ${last_week}) / ${last_week}"
      value_format:
      value_format_name: percent_0
    query_timezone: America/New_York
    custom_color_enabled: false
    custom_color: forestgreen
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    stacking: ''
    show_value_labels: false
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: true
    limit_displayed_rows: false
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_scale_mode: linear
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#1C2260"
    series_types: {}
    hidden_fields:
    - last_week_sessions
    - last_week
    comparison_label: week-over-week
    listen:
      new_vs_returning: snowplow_sessions.new_vs_returning
      device: snowplow_sessions.device_type
      traffic_source: snowplow_sessions.referer_source
    row: 0
    col: 12
    width: 6
    height: 4

    #Sessions -------------------------------------------------------
  - name: sessions
    title: Sessions
    model: snowplow_web_analytics
    explore: snowplow_sessions
    type: looker_line
    fields:
    - snowplow_sessions.session_start_date
    - snowplow_sessions.sessions
    fill_fields:
    - snowplow_sessions.session_start_date
    sorts:
    - snowplow_sessions.session_start_date desc
    limit: 500
    column_limit: 50
    dynamic_fields:
    - table_calculation: median
      label: median
      expression: median(${snowplow_sessions.sessions})
      value_format:
      value_format_name:
    query_timezone: America/New_York
    stacking: ''
    show_value_labels: false
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    limit_displayed_rows: false
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_scale_mode: linear
    show_null_points: true
    point_style: none
    interpolation: linear
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#1C2260"
    series_types:
      median: area
    hidden_series:
    - Game console
    - Unknown
    series_colors:
      median: "#e4e7e0"
      snowplow_sessions.sessions: "#EEC200"
    series_labels:
      median: below median
    focus_on_hover: false
    hide_legend: true
    listen:
      date_range: snowplow_sessions.session_start_date
      new_vs_returning: snowplow_sessions.new_vs_returning
      device: snowplow_sessions.device_type
      traffic_source: snowplow_sessions.referer_source
    row: 4
    col: 0
    width: 24
    height: 6

  #Sessions by Traffic Source -------------------------------------------------------
  - name: sessions_by_traffic_source
    title: Sessions by Traffic Source
    model: snowplow_web_analytics
    explore: snowplow_sessions
    type: looker_line
    fields:
    - snowplow_sessions.referer_source
    - snowplow_sessions.session_start_date
    - snowplow_sessions.sessions
    pivots:
    - snowplow_sessions.referer_source
    fill_fields:
    - snowplow_sessions.session_start_date
    sorts:
    - snowplow_sessions.referer_source 0
    - snowplow_sessions.session_start_date desc
    limit: 500
    column_limit: 50
    query_timezone: America/New_York
    stacking: ''
    show_value_labels: false
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    limit_displayed_rows: false
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_scale_mode: linear
    show_null_points: true
    point_style: none
    interpolation: linear
    show_row_numbers: true
    truncate_column_names: false
    hide_totals: false
    hide_row_totals: false
    table_theme: editable
    series_types: {}
    hidden_series:
    - email
    series_colors:
      Direct - snowplow_sessions.sessions: "#43467F"
      Email - snowplow_sessions.sessions: "#007ACE"
      Search - snowplow_sessions.sessions: "#EEC200"
      Social - snowplow_sessions.sessions: "#50B83C"
      Unknown - snowplow_sessions.sessions: "#47C1BF"
    listen:
      date_range: snowplow_sessions.session_start_date
      new_vs_returning: snowplow_sessions.new_vs_returning
      device: snowplow_sessions.device_type
      traffic_source: snowplow_sessions.referer_source
    row: 16
    col: 0
    width: 12
    height: 6

    #Time on Site -------------------------------------------------------
  - name: time_on_site
    title: Time on Site
    model: snowplow_web_analytics
    explore: snowplow_sessions
    type: looker_bar
    fields:
    - snowplow_sessions.session_duration_tier
    - snowplow_sessions.sessions
    filters:
      snowplow_sessions.session_duration_tier: "-NULL"
    sorts:
    - snowplow_sessions.sessions desc
    limit: 500
    column_limit: 50
    query_timezone: America/New_York
    stacking: ''
    show_value_labels: false
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    limit_displayed_rows: false
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_scale_mode: linear
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    truncate_column_names: true
    totals_color: "#1C2260"
    series_types: {}
    series_labels:
    series_name: Sessions
    listen:
      date_range: snowplow_sessions.session_start_date
      new_vs_returning: snowplow_sessions.new_vs_returning
      device: snowplow_sessions.device_type
      traffic_source: snowplow_sessions.referer_source
    row: 10
    col: 0
    width: 12
    height: 6

  #Last Week Uniques -------------------------------------------------------
  - name: sessions_by_device
    title: Sessions by Device
    model: snowplow_web_analytics
    explore: snowplow_sessions
    type: looker_line
    fields:
    - snowplow_sessions.session_start_date
    - snowplow_sessions.device_type
    - snowplow_sessions.sessions
    pivots:
    - snowplow_sessions.device_type
    fill_fields:
    - snowplow_sessions.session_start_date
    sorts:
    - snowplow_sessions.session_start_date desc
    - snowplow_sessions.device_type
    limit: 500
    column_limit: 50
    query_timezone: America/New_York
    stacking: ''
    show_value_labels: false
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    limit_displayed_rows: false
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_scale_mode: linear
    show_null_points: true
    point_style: none
    interpolation: linear
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    truncate_column_names: true
    series_name: Session Started Date
    totals_color: "#1C2260"
    series_types: {}
    series_colors:
      Desktop - snowplow_sessions.sessions: "#1C2260"
      Game Console - snowplow_sessions.sessions: "#007ACE"
      Mobile - snowplow_sessions.sessions: "#EEC200"
      Smart TV - snowplow_sessions.sessions: "#50B83C"
      Tablet - snowplow_sessions.sessions: "#47C1BF"
      Unknown - snowplow_sessions.sessions: "#5C6AC4"
    hidden_series:
    - Game console
    - Unknown
    listen:
      date_range: snowplow_sessions.session_start_date
      device: snowplow_sessions.device_type
      new_vs_returning: snowplow_sessions.new_vs_returning
      traffic_source: snowplow_sessions.referer_source
    row: 16
    col: 12
    width: 12
    height: 6

    #New vs Returning Sessions -------------------------------------------------------
  - name: new_vs_returning_sessions
    title: New vs Returning Sessions
    model: snowplow_web_analytics
    explore: snowplow_sessions
    type: looker_pie
    fields:
    - snowplow_sessions.new_vs_returning
    - snowplow_sessions.sessions
    sorts:
    - snowplow_sessions.sessions desc
    limit: 500
    column_limit: 50
    query_timezone: America/New_York
    value_labels: legend
    label_type: labPer
    stacking: ''
    show_value_labels: false
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: true
    limit_displayed_rows: false
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_scale_mode: linear
    show_null_points: true
    point_style: none
    interpolation: linear
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#1C2260"
    series_types: {}
    inner_radius: 60
    colors: 'palette: Looker Classic'
    series_colors:
      returning: "#EEC200"
      new: "#007ACE"
    listen:
      date_range: snowplow_sessions.session_start_date
      new_vs_returning: snowplow_sessions.new_vs_returning
      device: snowplow_sessions.device_type
      traffic_source: snowplow_sessions.referer_source
    row: 10
    col: 12
    width: 12
    height: 6

  #Sessions by Country -------------------------------------------------------
  - name: sessions_by_country
    title: Sessions by Country
    model: snowplow_web_analytics
    explore: snowplow_sessions
    type: looker_bar
    fields:
    - snowplow_sessions.geo_country
    - snowplow_sessions.sessions
    sorts:
    - snowplow_sessions.sessions desc
    limit: 20
    column_limit: 15
    dynamic_fields:
    - table_calculation: yesno
      label: yes/no
      expression: row()<=10
      value_format:
      value_format_name:
      _kind_hint: dimension
      _type_hint: yesno
    stacking: ''
    show_value_labels: false
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    limit_displayed_rows: false
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: false
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_scale_mode: linear
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#1C2260"
    show_null_points: true
    point_style: none
    interpolation: linear
    value_labels: legend
    label_type: labPer
    series_types: {}
    hidden_series: []
    x_axis_label: Product ID
    hidden_points_if_no:
    - yesno
    listen:
      date_range: snowplow_sessions.session_start_date
      new_vs_returning: snowplow_sessions.new_vs_returning
      device: snowplow_sessions.device_type
      traffic_source: snowplow_sessions.referer_source
    row: 28
    col: 0
    width: 12
    height: 6

  #Sessions by Landing Page Type -------------------------------------------------------
  - name: sessions_by_landing_page_title
    title: Sessions by Landing Page Title
    model: snowplow_web_analytics
    explore: snowplow_sessions
    type: looker_bar
    fields:
    - snowplow_sessions.first_page_title
    - snowplow_sessions.sessions
    filters:
      snowplow_sessions.first_page_title: "-NULL"
    sorts:
    - snowplow_sessions.sessions desc
    limit: 20
    column_limit: 15
    dynamic_fields:
    - table_calculation: yesno
      label: yes/no
      expression: row()<=10
      value_format:
      value_format_name:
      _kind_hint: dimension
      _type_hint: yesno
    stacking: ''
    show_value_labels: false
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    limit_displayed_rows: false
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: false
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_scale_mode: linear
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#1C2260"
    show_null_points: true
    point_style: none
    interpolation: linear
    value_labels: legend
    label_type: labPer
    series_types: {}
    series_colors:
      snowplow_sessions.sessions: "#EEC200"
    hidden_series: []
    x_axis_label: Product ID
    hidden_points_if_no:
    - yesno
    listen:
      date_range: snowplow_sessions.session_start_date
      new_vs_returning: snowplow_sessions.new_vs_returning
      device: snowplow_sessions.device_type
      traffic_source: snowplow_sessions.referer_source
    row: 28
    col: 12
    width: 12
    height: 6

  filters:
  - name: date_range
    title: Date Range
    type: field_filter
    default_value: last 12 months
    model: snowplow_web_analytics
    explore: snowplow_sessions
    field: snowplow_sessions.session_start_date
    listens_to_filters: []
    allow_multiple_values: true
    required: false
  - name: new_vs_returning
    title: New vs Returning
    type: field_filter
    default_value:
    model: snowplow_web_analytics
    explore: snowplow_sessions
    field: snowplow_sessions.new_vs_returning
    listens_to_filters: []
    allow_multiple_values: true
    required: false
  - name: device
    title: Device
    type: field_filter
    default_value:
    model: snowplow_web_analytics
    explore: snowplow_sessions
    field: snowplow_sessions.device_type
    listens_to_filters: []
    allow_multiple_values: true
    required: false
  - name: traffic_source
    title: Traffic Source
    type: field_filter
    default_value:
    model: snowplow_web_analytics
    explore: snowplow_sessions
    field: snowplow_sessions.referer_source
    listens_to_filters: []
    allow_multiple_values: true
    required: false
