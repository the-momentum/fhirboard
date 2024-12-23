class AnalysesController < ApplicationController
  before_action :set_analysis, only: %i[show update]

  def show
  end

  def new
    @analysis = Analysis.new
  end

  def update
    if @analysis.update(analysis_params)
      redirect_to analysis_path(@analysis), notice: "Analysis was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def create
    @analysis = Analysis.new(analysis_params)

    if @analysis.save
      redirect_to analysis_path(@analysis), notice: "Analysis was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def export_to_superset
    analysis = Analysis.find(params[:analysis_id])

    analysis.view_definitions.each do |vd|
      ::Superset::Services::ApiService.new.save_query(
        vd.duck_db_query, "[#{analysis.name}] #{vd.name}"
      )
    end
  end

  def save_as_views
    analysis = Analysis.find(params[:analysis_id])

    begin
      db  = DuckDB::Database.open("/app/fhir-export/duckdb_persistent.duckdb")
      con = db.connect

      analysis.view_definitions.each do |vd|
      
        query_result = ViewDefinitions::Services::GenerateQuery.new(vd, template_type: :create_view).call

        con.query(query_result)
      end
    rescue StandardError => e
      @error = e.message
      Rails.logger.error "Query error: #{e.message}"
    ensure
      con&.close
      db&.close
    end
  end

  private

    def analysis_params
      params.require(:analysis).permit(:export_path_url, :name, :description)
    end

    def set_analysis
      @analysis = Analysis.find(params[:id])
    end
end