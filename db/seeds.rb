# frozen_string_literal: true

## Create example analysis
Analysis.find_or_create_by!(
  name: "Distribution of Vaccinated Patients",
  description: "This analysis examines the age distribution of patients who received vaccinations in 2023. The data is grouped into 10-year age brackets to identify vaccination patterns across different age groups in our patient population.",
  export_path_url: "/app/fhir-export"
).tap do |analysis|
  Dir.glob("lib/examples/view_definitions/distribution_of_vaccinated_patients/*.json").each do |file_path|
    file_name      = File.basename(file_path, ".json")

    json_content   = File.read(file_path)
    parsed_json    = JSON.parse(json_content)
    formatted_json = JSON.pretty_generate(parsed_json)
  
    ViewDefinition.create!(
      name: file_name,
      content: formatted_json,
      analysis:
    )
  end
end

## Creating duckdb connection in Superset
existing_db_id = Setting.get("superset_duckdb_database_id")

if existing_db_id.present?
  puts "DuckDB database already exists with ID: #{existing_db_id}"
else
  response = ::Superset::Services::ApiService.new.create_database("duckdb_persistent")
  
  new_db_id = response.body["id"]
  
  Setting.set('superset_duckdb_database_id', new_db_id, 'integer')
  
  puts "Created new DuckDB database with ID: #{new_db_id}"
end