{% macro set_default_adapters() %}

    {% set default_adapters = ['postgres', 'redshift', 'snowflake', 'spark'] %}
    
    {% do return(default_adapters) %}

{% endmacro %}

{% macro is_adapter(adapter='default') %}

{#-
    This logic means that if you add your own macro named `set_default_adapters`
    to your project, that will be used, giving you the flexibility of overriding
    which target types use the default implementation of Snowplow models.
-#}

    {% if context.get(ref.config.project_name, {}).get('set_default_adapters')  %}
        {% set default_adapters=context[ref.config.project_name].set_default_adapters() %}
    {% else %}
        {% set default_adapters=snowplow.set_default_adapters() %}
    {% endif %}

    {% if adapter == 'default' %}
        {% set adapters = default_adapters %}
    {% elif adapter is string %}
        {% set adapters = [adapter] %}
    {% else %}
        {% set adapters = adapter %}
    {% endif %}
    
    {% set result = (target.type in adapters) %}
    
    {{return(result)}}

{% endmacro %}
