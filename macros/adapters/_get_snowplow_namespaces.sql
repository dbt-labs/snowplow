{% macro _get_utils_namespaces() %}
  {% set override_namespaces = var('snowplow_dispatch_list', []) %}
  {% do return(override_namespaces + ['snowplow']) %}
{% endmacro %}
