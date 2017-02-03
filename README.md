# snowplow data models #

dbt data models for snowplow analytics. Adapted from Snowplow's [web model](https://github.com/snowplow/snowplow/tree/master/5-data-modeling/web-model/redshift)

### models ###

The primary data models contained in this package are described below. While other models exist,
they are primarily used to build the three primary models listed here.

| model | description |
|-------|-------------|
| snowplow_page_views | Contains a list of pageviews with scroll depth, view timing, and optionally useragent and performance data. |
| snowplow_sessions | Contains a rollup of page views indexed by cookie id (`user_snowplow_domain_id`) |
| snowplow_users | Contains a rollup of users with information about their first and last sessions |

![snowplow graph](/etc/snowplow_graph.png)

### installation ###

- add the following lines to the bottom of your `dbt_project.yml` file:
```YAML
repositories:
  - "git@github.com:fishtown-analytics/snowplow.git"
```

- run `dbt deps`.

### configuration ###

The [variables](http://dbt.readthedocs.io/en/master/guide/context-variables/#arbitrary-configuration-variables) needed to configure this package are as follows:

| variable | information | required |
|----------|-------------|:--------:|
|snowplow:timezone|Timezone in which analysis takes place. Used to calculate local times.|No|
|snowplow:events|Schema and table containing all snowplow events|Yes|
|snowplow:context:web_page|Schema and table for web page context|Yes|
|snowplow:context:performance_timing|Schema and table for perf timing context, or `false` if none is present|Yes|
|snowplow:context:useragent|Schema and table for useragent context, or `false` if none is available|Yes|

An example `dbt_project.yml` configuration is provided below
```yml
# dbt_project.yml

...

models:
    snowplow:
        vars:
            'snowplow:timezone': 'America/New_York'
            'snowplow:events': "{{ ref('sp_base_events') }}"
            'snowplow:context:web_page': "{{ ref('sp_base_web_page_context') }}"
            'snowplow:context:performance_timing': false
            'snowplow:context:useragent': false
    base:
      optional:
        enabled: false
    page_views:
      optional:
        enabled: false

...

repositories:
  - "git@github.com:fishtown-analytics/snowplow.git"
```

### contribution ###

Additional contributions to this repo are very welcome! Please submit PRs to master. All PRs should only include functionality that is contained within all snowplow deployments; no implementation-specific details should be included.
