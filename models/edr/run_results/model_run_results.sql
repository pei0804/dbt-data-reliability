{{
  config(
    materialized = 'view',
    bind=False
  )
}}

with dbt_run_results as (
    select * from {{ ref('dbt_run_results') }}
),

dbt_models as (
    select * from {{ ref('dbt_models') }}
)

SELECT
    run_results.model_execution_id,
    run_results.unique_id,
    run_results.invocation_id,
    run_results.name,
    run_results.generated_at,
    run_results.status,
    run_results.full_refresh,
    run_results.message,
    run_results.execution_time,
    run_results.execute_started_at,
    run_results.execute_completed_at,
    run_results.compile_started_at,
    run_results.compile_completed_at,
    run_results.compiled_code,
    models.database_name,
    models.schema_name,
    models.materialization,
    models.tags,
    models.package_name,
    models.path,
    models.original_path,
    models.owner,
    models.alias,
    ROW_NUMBER() OVER (PARTITION BY run_results.unique_id ORDER BY run_results.generated_at DESC) AS model_invocation_reverse_index,
    CASE WHEN DENSE_RANK() OVER (ORDER BY run_results.generated_at DESC) = 1 THEN TRUE ELSE FALSE END AS is_latest_invocation, 
    CASE WHEN DENSE_RANK() OVER (PARTITION BY {{ elementary.time_trunc('day', 'run_results.generated_at') }} ORDER BY run_results.generated_at ASC) = 1 THEN TRUE ELSE FALSE END AS is_the_first_invocation_of_the_day
    
FROM dbt_run_results run_results
JOIN dbt_models models ON run_results.unique_id = models.unique_id
