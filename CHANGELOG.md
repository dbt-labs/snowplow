# snowplow 0.14.0

This release supports any version (minor and patch) of v1, which means far less need for compatibility releases in the future.

## Under the hood
- Change `require-dbt-version` to `[">=1.0.0", "<2.0.0"]`
- Bump dbt-utils dependency
- Replace `source-paths` and `data-paths` with `model-paths` and `seed-paths` respectively
- Rename `data` and `analysis` directories to `seeds` and `analyses` respectively
- Replace `dbt_modules` with `dbt_packages` in `clean-targets`

# snowplow v0.13.3
🚨 This is a compatibility release in preparation for `dbt-core` v1.0.0 (🎉). Projects using this version with `dbt-core` v1.0.x can expect to see a deprecation warning. This will be resolved in the next minor release.