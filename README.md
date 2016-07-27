# snowplow
Data models for snowplow analytics.

Currently, these models support sessionization. Future iterations may support more snowplow functionality.

To use this repo, do the following:

- modify your `profiles.yml` to include the following:
```YAML
repositories:
  - "git@github.com:fishtown-analytics/snowplow.git"
```

- create an events model within your project. this model should just be a `select *` on wherever your snowplow events table lives.
- run `dbt deps`.
