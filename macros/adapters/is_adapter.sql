{% macro is_adapter(adapter_type='default') %}
    
    {{ return(adapter.dispatch('is_adapter', 'snowplow') (adapter_type)) }}

{% endmacro %}

{% macro default__is_adapter(adapter_type='default') %}

    {% set result = (adapter_type == 'default') %}
    {{return(result)}}

{% endmacro %}

{% macro bigquery__is_adapter(adapter_type='default') %}

    {% set result = (adapter_type == 'bigquery') %}
    {{return(result)}}
    
{% endmacro %}
