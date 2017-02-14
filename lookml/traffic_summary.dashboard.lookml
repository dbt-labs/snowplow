- dashboard: traffic_summary
  title: Traffic Summary
  layout: grid
  width: 800
  rows:
    - elements: [last_week_sessions, last_week_uniques, last_week_bounce_rate]
      height: 200
    - elements: [sessions]
      height: 300
    - elements: [sessions_by_traffic_source, time_on_site]
      height: 300
    - elements: [sessions_by_device, new_vs_returning_sessions]
      height: 300


  filters:

  elements:
    - name: last_week_sessions
      title: Last Week Sessions
      type: single_value
      model: snowplow_web_analytics
      explore: snowplow_sessions
      dimensions: [snowplow_sessions.session_start_week]
      fill_fields: [snowplow_sessions.session_start_week]
      measures: [snowplow_sessions.sessions]
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
      filters:
        snowplow_sessions.session_start_week: 2017/01/30 to 2017/02/13
      sorts: [snowplow_sessions.session_start_week desc]
      limit: '500'
      column_limit: '50'
      query_timezone: America/Los_Angeles
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
      totals_color: "#808080"
      series_types: {}
      hidden_fields: [last_week_sessions]
      comparison_label: week-over-week

    - name: last_week_uniques
      title: Last Week Uniques
      type: single_value
      model: snowplow_web_analytics
      explore: snowplow_sessions
      dimensions: [snowplow_sessions.session_start_week]
      fill_fields: [snowplow_sessions.session_start_week]
      measures: [snowplow_sessions.distinct_users]
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
      filters:
        snowplow_sessions.session_start_week: 2017/01/30 to 2017/02/13
      sorts: [snowplow_sessions.session_start_week desc]
      limit: '500'
      column_limit: '50'
      query_timezone: America/Los_Angeles
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
      totals_color: "#808080"
      series_types: {}
      hidden_fields: [last_week_sessions, last_week]
      comparison_label: week-over-week


    - name: last_week_bounce_rate
      title: Last Week Bounce Rate
      type: single_value
      model: snowplow_web_analytics
      explore: snowplow_sessions
      dimensions: [snowplow_sessions.session_start_week]
      fill_fields: [snowplow_sessions.session_start_week]
      measures: [snowplow_sessions.bounce_rate]
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
      filters:
        snowplow_sessions.session_start_week: 2017/01/30 to 2017/02/13
      sorts: [snowplow_sessions.session_start_week desc]
      limit: '500'
      column_limit: '50'
      query_timezone: America/Los_Angeles
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
      totals_color: "#808080"
      series_types: {}
      hidden_fields: [last_week_sessions, last_week]
      comparison_label: week-over-week




    - name: sessions
      title: Sessions
      type: looker_line
      model: snowplow_web_analytics
      explore: snowplow_sessions
      dimensions: [snowplow_sessions.session_start_date]
      fill_fields: [snowplow_sessions.session_start_date]
      measures: [snowplow_sessions.sessions]
      dynamic_fields:
      - table_calculation: median
        label: median
        expression: median(${snowplow_sessions.sessions})
        value_format:
        value_format_name:
      filters:
        snowplow_sessions.session_start_date: 2017/01/30 to 2017/02/13
      sorts: [snowplow_sessions.session_start_date desc]
      limit: '500'
      column_limit: '50'
      query_timezone: America/Los_Angeles
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
      totals_color: "#808080"
      series_types:
        median: area
      hidden_series: [Game console, Unknown]
      series_colors:
        median: "#e4e7e0"
      series_labels:
        median: below median
      focus_on_hover: false
      hide_legend: true




    - name: sessions_by_traffic_source
      title: Sessions by Traffic Source
      type: looker_line
      model: snowplow_web_analytics
      explore: snowplow_sessions
      dimensions: [snowplow_sessions.referer_medium, snowplow_sessions.session_start_date]
      pivots: [snowplow_sessions.referer_medium]
      fill_fields: [snowplow_sessions.session_start_date]
      measures: [snowplow_sessions.sessions]
      filters:
        snowplow_sessions.session_start_date: 2017/01/30 to 2017/02/13
      sorts: [snowplow_sessions.referer_medium 0, snowplow_sessions.session_start_date desc]
      limit: '500'
      column_limit: '50'
      query_timezone: America/Los_Angeles
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
      hidden_series: [email]




    - name: time_on_site
      title: Time on Site
      type: looker_bar
      model: snowplow_web_analytics
      explore: snowplow_sessions
      dimensions: [snowplow_sessions.time_engaged_in_s_tier]
      measures: [snowplow_sessions.sessions]
      filters:
        snowplow_sessions.session_end_local_date: 2017/01/30 to 2017/02/13
      sorts: [snowplow_sessions.sessions desc]
      limit: '500'
      column_limit: '50'
      query_timezone: America/Los_Angeles
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
      totals_color: "#808080"
      series_types: {}




    - name: sessions_by_device
      title: Sessions by Device
      type: looker_line
      model: snowplow_web_analytics
      explore: snowplow_sessions
      dimensions: [snowplow_sessions.session_start_date, snowplow_sessions.device_type]
      pivots: [snowplow_sessions.device_type]
      fill_fields: [snowplow_sessions.session_start_date]
      measures: [snowplow_sessions.sessions]
      filters:
        snowplow_sessions.device_type: Computer,Mobile,Tablet
        snowplow_sessions.session_start_date: 2017/01/30 to 2017/02/13
      sorts: [snowplow_sessions.session_start_date desc, snowplow_sessions.device_type]
      limit: '500'
      column_limit: '50'
      query_timezone: America/Los_Angeles
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
      totals_color: "#808080"
      series_types: {}
      hidden_series: [Game console, Unknown]



    - name: new_vs_returning_sessions
      title: New vs Returning Sessions
      type: looker_pie
      model: snowplow_web_analytics
      explore: snowplow_sessions
      dimensions: [snowplow_sessions.new_vs_returning]
      measures: [snowplow_sessions.sessions]
      filters:
        snowplow_sessions.session_start_date: 2017/01/30 to 2017/02/13
      sorts: [snowplow_sessions.sessions desc]
      limit: '500'
      column_limit: '50'
      query_timezone: America/Los_Angeles
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
      totals_color: "#808080"
      series_types: {}
      inner_radius: 60
      colors: 'palette: Looker Classic'
      series_colors: {}
