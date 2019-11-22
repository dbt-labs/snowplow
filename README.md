# Snowplow sessionization

dbt data models for sessionizing Snowplow data. Adapted from Snowplow's [web model](https://github.com/snowplow/web-data-model).

### Models ###

The primary ouputs of this package are **page views** and **sessions**. There are
several intermediate models used to create these two models.

| model | description |
|-------|-------------|
| snowplow_page_views | Contains a list of pageviews with scroll depth, view timing, and optionally useragent and performance data. |
| snowplow_sessions | Contains a rollup of page views indexed by cookie id (`domain_sessionid`) |

![snowplow graph](/etc/snowplow_graph.png)

## Installation Instructions
Check [dbt Hub](https://hub.getdbt.com/fishtown-analytics/snowplow/latest/) for
the latest installation instructions, or [read the docs](https://docs.getdbt.com/docs/package-management)
for more information on installing packages.

## Configuration ###

The [variables](https://docs.getdbt.com/docs/using-variables) needed to configure this package are as follows:

| variable | information | required |
|----------|-------------|:--------:|
|snowplow:timezone|Timezone in which analysis takes place. Used to calculate local times.|No|
|snowplow:page_ping_frequency|Configured timeout for page pings in tracker (seconds). Default=30|No|
|snowplow:events|Schema and table containing all snowplow events|Yes|
|snowplow:context:web_page|Schema and table for web page context. If false, `page_view_id` is assumed to be present as a column in the canonical events table or (on Snowflake) embedded in a `contexts` JSON object.|Yes|
|snowplow:context:performance_timing|Schema and table for perf timing context, or `false` if none is present|Yes|
|snowplow:context:useragent|Schema and table for useragent context, or `false` if none is available|Yes|
|snowplow:pass_through_columns|Additional columns for inclusion in final models|No|
|snowplow:page_view_lookback_days|Amount of days to rescan to merge page_views in the same session|Yes|

An example `dbt_project.yml` configuration:

```yml
# dbt_project.yml

...

models:
    snowplow:
        vars:
            'snowplow:timezone': 'America/New_York'
            'snowplow:page_ping_frequency': 10
            'snowplow:events': "{{ ref('sp_base_events') }}"
            'snowplow:context:web_page': false
            'snowplow:context:performance_timing': false
            'snowplow:context:useragent': false
            'snowplow:pass_through_columns': []
            'snowplow:page_view_lookback_days': 1
    base:
      optional:
        enabled: false
    page_views:
      optional:
        enabled: false
```

### Database support

* Redshift
* Snowflake
* BigQuery
* Postgres, with the creation of [these UDFs](pg_udfs.sql)

### Contributions ###

Additional contributions to this package are very welcome! Please create issues
or open PRs against `master`.

Much of tracking can be the Wild West. Snowplow's canonical event model is a major 
asset in our ability to perform consistent analysis atop predictably structured 
data, but any detailed implementation is bound to diverge.

To that end, we aim to keep this package rooted in a garden-variety Snowplow web
deployment. All PRs should seek to add or improve functionality that is contained 
within a plurality of snowplow deployments.

If you need to change implementation-specific details, you have two avenues:

* Override models from this package with versions that feature your custom logic.
Create a model with the same name locally (e.g. `snowplow_id_map`) and disable the `snowplow` 
package's version in `dbt_project.yml`:

```yml
snowplow:
    ...
    identification:
      snowplow_id_map:
        enabled: false
```
* Fork this repository :)
