# Snowplow Base Events
{% docs snowplow_base_events %}

This model is the Snowplow package's base model for the core Snowplow Events table. All tracking calls fired by any one of the Snowplow client libraries will create a record in this table. There are many fields provided on this model; descriptions can be viewed in the table below and you can learn more information about them in the [Snowplow Canonical Event Model documentation on the Snowplow website](https://github.com/snowplow/snowplow/wiki/Canonical-event-model#platform).

This model is responsible for filtering out events that we don't want include in any downstream analytics, including those from `app_id`s that we don't want included, and malformed data that the collector receives.

{% enddocs %}

