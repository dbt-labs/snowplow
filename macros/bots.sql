{% macro bot_any() %}

    {% set all_my_bots = [
        'bot',
        'crawl',
        'slurp',
        'spider',
        'archiv',
        'spinn',
        'sniff',
        'seo',
        'audit',
        'survey',
        'pingdom',
        'worm',
        'capture',
        'browsershots',
        'screenshots',
        'analyz',
        'index',
        'thumb',
        'check',
        'facebook',
        'phantomjs',
        'a_archiver',
        'facebookexternalhit',
        'bingpreview',
        'baiduspider',
        '360spider',
        '360user-agent',
        'semalt'
        ] %}
        
    {% do return(all_my_bots) %}

{% endmacro %}