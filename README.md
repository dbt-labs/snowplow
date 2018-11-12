# snowplow data models

dbt data models for snowplow analytics. Adapted from Snowplow's [web model](https://github.com/snowplow/web-data-model)

### models ###

The primary data models contained in this package are described below. While other models exist,
they are primarily used to build the two primary models listed here.

| model | description |
|-------|-------------|
| snowplow_page_views | Contains a list of pageviews with scroll depth, view timing, and optionally useragent and performance data. |
| snowplow_sessions | Contains a rollup of page views indexed by cookie id (`user_snowplow_domain_id`) |

![snowplow graph](/etc/snowplow_graph.png)

### installation ###

- add the following lines to the bottom of your `dbt_project.yml` file:
```YAML
repositories:
  - https://github.com/fishtown-analytics/snowplow.git
```

- run `dbt deps`.

### configuration ###

The [variables](http://dbt.readthedocs.io/en/master/guide/context-variables/#arbitrary-configuration-variables) needed to configure this package are as follows:

| variable | information | required |
|----------|-------------|:--------:|
|snowplow:timezone|Timezone in which analysis takes place. Used to calculate local times.|No|
|snowplow:page_ping_frequency|Configured timeout for page pings in tracker (seconds). Default=30|No|
|snowplow:events|Schema and table containing all snowplow events|Yes|
|snowplow:context:web_page|Schema and table for web page context|Yes|
|snowplow:context:performance_timing|Schema and table for perf timing context, or `false` if none is present|Yes|
|snowplow:context:useragent|Schema and table for useragent context, or `false` if none is available|Yes|

An example `dbt_project.yml` configuration is provided below
```yml
# dbt_project.yml

...

models:
    snowplow:
        vars:
            'snowplow:timezone': 'America/New_York'
            'snowplow:page_ping_frequency': 10
            'snowplow:events': "{{ ref('sp_base_events') }}"
            'snowplow:context:web_page': "{{ ref('sp_base_web_page_context') }}"
            'snowplow:context:performance_timing': false
            'snowplow:context:useragent': false
    base:
      optional:
        enabled: false
    page_views:
      optional:
        enabled: false

...

repositories:
  - "git@github.com:fishtown-analytics/snowplow.git"
```

### database support

These models were written for Redshift, but have also been tested with Postgres. If you're using Postgres, create the following UDFs in your database.

```sql
create function convert_timezone(
    in_tzname text,
    out_tzname text,
    in_t timestamptz
    ) returns timestamptz
as $$
declare
begin
  return in_t at time zone out_tzname at time zone in_tzname;
end;
$$ language plpgsql;
```

```sql
create or replace function datediff(
    units varchar(30),
    start_t timestamp,
    end_t timestamp) returns int
as $$
declare
    diff_interval interval; 
    diff int = 0;
    years_diff int = 0;
begin
    if units in ('yy', 'yyyy', 'year', 'mm', 'm', 'month') then
        years_diff = date_part('year', end_t) - date_part('year', start_t);

        if units in ('yy', 'yyyy', 'year') then
            -- sql server does not count full years passed (only difference between year parts)
            return years_diff;
        else
            -- if end month is less than start month it will subtracted
            return years_diff * 12 + (date_part('month', end_t) - date_part('month', start_t)); 
        end if;
    end if;

    -- Minus operator returns interval 'DDD days HH:MI:SS'  
    diff_interval = end_t - start_t;

    diff = diff + date_part('day', diff_interval);

    if units in ('wk', 'ww', 'week') then
        diff = diff/7;
        return diff;
    end if;

    if units in ('dd', 'd', 'day') then
        return diff;
    end if;

    diff = diff * 24 + date_part('hour', diff_interval); 

    if units in ('hh', 'hour') then
        return diff;
    end if;

    diff = diff * 60 + date_part('minute', diff_interval);

    if units in ('mi', 'n', 'minute') then
        return diff;
    end if;

    diff = diff * 60 + date_part('second', diff_interval);

    return diff;
end;
$$ language plpgsql;
```


### contribution ###

Additional contributions to this repo are very welcome! Please submit PRs to master. All PRs should only include functionality that is contained within all snowplow deployments; no implementation-specific details should be included.
