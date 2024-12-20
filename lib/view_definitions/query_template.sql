{{fq_sql_macros}}


WITH transformed AS (
  SELECT {{fq_sql_transform_expression}} AS result 
  FROM read_json_auto(
    '{{path}}/**/*{{fq_vd_resource}}*.ndjson'
    {{fq_sql_input_schema}}
  )
  {{fq_where_filter}}
)
SELECT {{fq_sql_flattening_cols}}
FROM transformed
{{fq_sql_flattening_tables}}
LIMIT 10;