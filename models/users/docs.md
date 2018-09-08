# Snowplow Users
{% docs snowplow_users %}

A users table is one of the core models in web event analytics.

A users table is a rollup of the sessions table which contains one row per user over their entire event stream. It contains detailed information about the user's first session and the date of their last session. 

Modeling users can provide insight into behavior patterns across all users. Common metrics to made available are: user retention, lifetime value, or categorize by behavioral segments.  

Here is a [detailed view of fields](https://github.com/snowplow/web-data-model#33-users-table) that the users table provides.

The events in this table are recorded by [Snowplow](http://github.com/snowplow/snowplow) and piped into the warehouse on an hourly basis. 

{% enddocs %}