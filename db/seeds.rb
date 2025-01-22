# frozen_string_literal: true

## Create example analysis
Analysis.find_or_create_by!(
  name: "Distribution of Vaccinated Patients",
  description: "This analysis examines the age distribution of patients who received vaccinations in 2023. The data is grouped into 10-year age brackets to identify vaccination patterns across different age groups in our patient population.",
  export_path_url: "/app/fhir-export",
  sample: true
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
