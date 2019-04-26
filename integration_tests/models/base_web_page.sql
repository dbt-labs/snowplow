
select * from {{ ref('sp_web_page') }}

{% if var('update', False) %}

    union all

    select * from {{ ref('sp_web_page_update') }}

{% endif %}
