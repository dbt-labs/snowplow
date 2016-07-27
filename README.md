# snowplow
Data models for snowplow analytics.

Currently, these models support sessionization. Future iterations may support more snowplow functionality.

To use this repo, do the following:

- modify your `profiles.yml` to include the following:
```YAML
repositories:
  - "git@github.com:fishtown-analytics/snowplow.git"
```

- copy the models within the `base-models` directory into your dbt project and modify them so that they select from the appropriate tables within your environment.
- run `dbt deps`.

At this point, `dbt run` should work successfully.
