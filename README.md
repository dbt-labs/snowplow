# Snowplow sessionization

This dbt package:
* Rolls up `page_view` and `page_ping` events into page views and sessions
* Performs "user stitching" to tie all historical events associated with an 
anonymous cookie (`domain_userid`) to the same `user_id`

Adapted from Snowplow's [web model](https://github.com/snowplow/web-data-model).

### Models ###

The primary ouputs of this package are **page views** and **sessions**. There are
several intermediate models used to create these two models.

| model | description |
|-------|-------------|
| snowplow_page_views | Contains a list of pageviews with scroll depth, view timing, and optionally useragent and performance data. |
| snowplow_sessions | Contains a rollup of page views indexed by cookie id (`domain_sessionid`) |

![snowplow graph](/etc/snowplow_graph.png)


## Prerequisites

This package takes the Snowplow JavaScript tracker as its foundation. It assumes 
that all Snowplow events are sent with a
[`web_page` context](https://github.com/snowplow/snowplow/wiki/1-General-parameters-for-the-Javascript-tracker#webPage).

### Mobile

It _is_ possible to sessionize mobile (app) events by including two predefined contexts with all events:
* [`client_session`](https://github.com/snowplow/iglu-central/blob/master/schemas/com.snowplowanalytics.snowplow/client_session/jsonschema/1-0-1) ([iOS](https://docs.snowplowanalytics.com/docs/collecting-data/collecting-from-own-applications/objective-c-tracker/objective-c-1-2-0/#session-tracking), [Android](https://github.com/snowplow/snowplow/wiki/Android-Tracker#12-client-sessions))
* [`screen`](https://github.com/snowplow/iglu-central/blob/master/schemas/com.snowplowanalytics.mobile/screen/jsonschema/1-0-0)

As long as all events are associated with an anonymous user, a session, and a 
screen/page view, they can be made to fit the same canonical data model as web 
events fired from the JavaScript tracker. Whether this is the desired outcome 
will vary significantly; mobile-first analytics often makes different 
assumptions about user identity, engagement, referral, and inactivity cutoffs.

For specific implementation details:
* [iOS](https://docs.snowplowanalytics.com/docs/collecting-data/collecting-from-own-applications/objective-c-tracker/)
* [Android trackers](https://docs.snowplowanalytics.com/docs/collecting-data/collecting-from-own-applications/android-tracker/)

## Installation Instructions
Check [dbt Hub](https://hub.getdbt.com/dbt-labs/snowplow/latest/) for
the latest installation instructions, or [read the docs](https://docs.getdbt.com/docs/package-management)
for more information on installing packages.

## Configuration ###

The [variables](https://docs.getdbt.com/docs/using-variables) needed to configure this package are as follows:

| variable | information | required |
|----------|-------------|:--------:|
|snowplow:timezone|Timezone in which analysis takes place. Used to calculate local times.|No|
|snowplow:page_ping_frequency|Configured timeout for page pings in tracker (seconds). Default=30|No|
|snowplow:events|Schema and table containing all snowplow events|Yes|
|snowplow:context:web_page|Schema and table for web page context|Yes|
|snowplow:context:performance_timing|Schema and table for perf timing context, or `false` if none is present|Yes|
|snowplow:context:useragent|Schema and table for useragent context, or `false` if none is available|Yes|
|snowplow:pass_through_columns|Additional columns for inclusion in final models|No|
|snowplow:page_view_lookback_days|Amount of days to rescan to merge page_views in the same session|Yes|

An example `dbt_project.yml` configuration:

```yml
# dbt_project.yml

...

vars:
  'snowplow:timezone': 'America/New_York'
  'snowplow:page_ping_frequency': 10
  'snowplow:events': "{{ ref('sp_base_events') }}"
  'snowplow:context:web_page': "{{ ref('sp_base_web_page_context') }}"
  'snowplow:context:performance_timing': false
  'snowplow:context:useragent': false
  'snowplow:pass_through_columns': []
  'snowplow:page_view_lookback_days': 1
```

### Database support

Core:
* Redshift
* Snowflake
* BigQuery
* Postgres

Plugins:
* Spark (via [`spark_utils`](https://github.com/dbt-labs/spark-utils))

### Contributions ###

Additional contributions to this package are very welcome! Please create issues
or open PRs against `master`. Check out 
[this post](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) 
on the best workflow for contributing to a package..

Much of tracking can be the Wild West. Snowplow's canonical event model is a major 
asset in our ability to perform consistent analysis atop predictably structured 
data, but any detailed implementation is bound to diverge.

To that end, we aim to keep this package rooted in a garden-variety Snowplow web
deployment. All PRs should seek to add or improve functionality that is contained 
within a plurality of Snowplow deployments.

If you need to change implementation-specific details, you have two avenues:

* Override models from this package with versions that feature your custom logic.
Create a model with the same name locally (e.g. `snowplow_id_map`) and disable 
the `snowplow` package's version in `dbt_project.yml`:

```yml
snowplow:
    ...
    identification:
      default:
        snowplow_id_map:
          +enabled: false
```
* Fork this repository :)
