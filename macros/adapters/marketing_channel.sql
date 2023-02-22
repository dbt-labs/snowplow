{%- macro marketing_channel() %}
    {{ return(adapter.dispatch('marketing_channel', 'snowplow')()) }}
{%- endmacro -%}

{% macro default__marketing_channel() %}

    case
        when
            mkt_medium is null
        then 'direct'

        when
            lower(mkt_medium) = 'organic'
        then 'organic_search'

        when
            regexp_contains(lower(mkt_medium), '^.*(social|social-network|social-media|sm|social network|social media).*$')
            or lower(mkt_source) = 'referral'
        then 'social'

        when
            lower(mkt_medium) = 'email'
        then 'email'

        when
            lower(mkt_medium) = 'affiliate'
        then 'affiliate'

        when
            lower(mkt_medium) = 'referral'
        then 'referral'

        when
            regexp_contains(lower(mkt_medium), '^.*(cpc|ppc|paidsearch).*$')
            and lower(mkt_network) != 'content'
        then 'paid_search'

        when
            regexp_contains(lower(mkt_medium), '^.*(cpv|cpa|cpp|content-text).*$')
        then 'other_advertising'

        when
            regexp_contains(lower(mkt_medium), '^.*(display|cpm|banner).*$')
            or lower(mkt_network) = 'content'
        then 'display'

        else 'other'
    
    end

{% endmacro %}