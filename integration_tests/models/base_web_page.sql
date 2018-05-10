
select * from {{ ref('web_page') }}

{% if var('update', False) %}

    union all

    select * from {{ ref('web_page_update') }}

{% endif %}
