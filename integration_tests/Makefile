
test-redshift:
	dbt seed --target redshift --full-refresh
	dbt run --target redshift --full-refresh --vars 'update: false'
	dbt run --target redshift --vars 'update: true'
	dbt test --target redshift

test-snowflake:
	dbt seed --target snowflake --full-refresh
	dbt run --target snowflake --full-refresh --vars 'update: false'
	dbt run --target snowflake --vars 'update: true'
	dbt test --target snowflake

test-bigquery:
	dbt seed --target bigquery --full-refresh
	dbt run --target bigquery --full-refresh --vars 'update: false'
	dbt run --target bigquery --vars 'update: true'
	dbt test --target bigquery --schema # ONLY RUN SCHEMA TESTS ON BQ. TODO!

test-all: test-redshift test-snowflake test-bigquery
	echo "Completed successfully"
