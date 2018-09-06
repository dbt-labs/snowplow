
{% docs snowplow_page_views %}

A page views table is one of the core models in web event analytics. Page views are a specific type of web event and must be explicitly modeled to filter out other types of events. 

Page views are inherently useful for analysis but also a building block for the sessionization of events. Page views provide insight to the volume of traffic a site receives down to the specific urls and which url a user landed from. 

Here is a [detailed view of fields](https://github.com/snowplow/web-data-model#31-page-views-table) that the page views table provides.

The events in this table are recorded by [Snowplow](http://github.com/snowplow/snowplow) and piped into the warehouse on an hourly basis. 

{% enddocs %}

