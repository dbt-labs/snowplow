{% macro is_adapter(adapter='default') %}

    {% if adapter == 'default' %}
        {% set adapters = ['postgres', 'redshift', 'snowflake'] %}
    {% elif adapter is string %}
        {% set adapters = [adapter] %}
    {% else %}
        {% set adapters = adapter %}
    {% endif %}
    
    {% set result = (target.type in adapters) %}
    
    {{return(result)}}

{% endmacro %}
