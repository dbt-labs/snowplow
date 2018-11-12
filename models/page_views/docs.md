# Snowplow Page Views
{% docs snowplow_page_views %}

Page views are a subset of all Snowplow events: page view events are fired by the Snowplow javascript tracker and form the base of this model. The goal of this model is to enrich page view events to include other useful information such as scroll height, time on page, and page view index. Many of these enrichments are performed within upstream models and joined here.

Page views are the primary input into sessions. If there is ever any additional information from the page view stream that an analysts wants to get that is not present in the the `snowplow_sessions` model, querying this table directly is a good idea. Doing so should be done with care, however, as this table is frequently quite large. Typically analysis done on this table should first be aggregated at the session level rather than being queried on the fly for performance reasons.

View the Snowplow canonical docs on this model [here](https://github.com/snowplow/web-data-model#31-page-views-table).

{% enddocs %}

