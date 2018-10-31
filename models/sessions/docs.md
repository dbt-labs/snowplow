# Snowplow Sessions
{% docs snowplow_sessions %}

A sessions table is one of the core models in web event analytics.

A sessions table is a rollup of page views and provides user stitching, a tying of events an individual user takes across devices and browsers.
 
Sessionization is a grouping of events by user, which shows the series of actions a user takes when visiting a site. These series of actions are a window into a user's behavior.

Here is a [detailed view of fields](https://github.com/snowplow/web-data-model#32-sessions-table) that the sessions table provides.

The events in this table are recorded by [Snowplow](http://github.com/snowplow/snowplow) and piped into the warehouse on an hourly basis. 

{% enddocs %}