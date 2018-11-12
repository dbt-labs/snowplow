# Snowplow ID Map
{% docs snowplow_id_map %}

This model maps a `domain_userid` (a cookie or device) to the most recent `user_id`. This mapping is the core of "identity stitching", the process whereby events fired prior to user authentication get associated with the authenticated `user_id` during the modeling process.

It is important to note that this mapping and the ensuing user stitching make the assumption that there will only ever be a single valid user authenticating within a single `domain_userid` (cookie or device). This is typically a good assumption to make, but if your use case relies on multiple users logging in on a shared workstation (or similar) you may want to build your own custom identity stitching logic.

{% enddocs %}

