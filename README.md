# snowplow data models #

dbt data models for snowplow analytics.

Currently, these models support sessionization. Future iterations may support more snowplow functionality.


### installation ###

- modify your `profiles.yml` to include the following:
```YAML
repositories:
  - "git@github.com:fishtown-analytics/snowplow.git"
```

- copy the models within the `base-models` directory into your dbt project and modify them so that they select from the appropriate tables within your environment.
- run `dbt deps`.

### usage ###

Once installation is completed, `dbt run` will build these models along with the other models in your project.

### contribution ###

Additional contributions to this repo are very welcome! Please submit PRs to master. All PRs should only include functionality that is contained within all snowplow deployments; no implementation-specific details should be included.
