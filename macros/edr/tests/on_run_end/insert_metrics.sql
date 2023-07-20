{% macro insert_metrics() %}
  {% set model_metrics = elementary.get_cache("tables").get("metrics") %}
  {% set database_name, schema_name = elementary.get_package_database_and_schema() %}
  {%- set target_relation = adapter.get_relation(database=database_name, schema=schema_name, identifier='data_monitoring_metrics') -%}
  {% if not target_relation %}
    {% do exceptions.raise_compiler_error("Couldn't find Elementary's models. Please run `dbt run -s elementary`.") %}
  {% endif %}

  {{ elementary.file_log("Inserting metrics into {}.".format(target_relation)) }}
  {% do elementary.insert_rows(target_relation, model_metrics, should_commit=true) %}
  {{ return('') }}
{% endmacro %}
