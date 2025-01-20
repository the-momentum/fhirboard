class ViewDefinitionsController < ApplicationController
  include SessionScoped

  before_action :set_view_definition, only: %i[show edit update destroy]
  before_action :set_view_definition_by_view_definition_id,
                only: %i[generate_query run_query save_to_superset execute_query]

  def index
    @view_definitions = session_scoped_resource(ViewDefinition)
  end

  def show; end

  def new
    @view_definition = ViewDefinition.new
  end

  def edit; end

  def create
    begin
      @view_definition = ViewDefinition.new(altered_params.merge(session: current_session))
      if @view_definition.save
        redirect_to analysis_path(@view_definition.analysis), notice: "View definition was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    rescue JSON::ParserError
      @view_definition = ViewDefinition.new(view_definition_params)
      @view_definition.errors.add(:content, "must be valid JSON")
      render :new, status: :unprocessable_entity
    rescue KeyError
      @view_definition = ViewDefinition.new(view_definition_params)
      @view_definition.errors.add(:content, "must contain a 'name' field")
      render :new, status: :unprocessable_entity
    end
  end

  def update
    begin
      if @view_definition.update(altered_params)
        redirect_to analysis_path(@view_definition.analysis), notice: "View definition was successfully updated.", status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    rescue JSON::ParserError
      @view_definition.errors.add(:content, "must be valid JSON")
      render :edit, status: :unprocessable_entity
    rescue KeyError
      @view_definition.errors.add(:content, "must contain a 'name' field")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @view_definition.destroy!
    redirect_to view_definitions_url, notice: "View definition was successfully destroyed.", status: :see_other
  end

  def generate_query
    @query_result = ViewDefinitions::Services::GenerateQuery.new(@view_definition).call

    @view_definition.update(duck_db_query: @query_result)

    respond_to do |format|
      format.turbo_stream
    end
  end

  def run_query
    @query = @view_definition.duck_db_query

    Rails.logger.info "Executing query: #{@query}"

    begin
      db = DuckDB::Database.open("lib/fhir-export/#{@current_session.token}.duckdb")
      con = db.connect

      @result = con.query(@query)
    rescue StandardError => e
      @error = e.message
      Rails.logger.error "Query error: #{e.message}"
    ensure
      con&.close
      db&.close
    end

    respond_to do |format|
      format.turbo_stream
    end
  end

  def save_to_superset
    res = ::Superset::Services::ApiService.new(current_session:).save_query(
      @view_definition.duck_db_query, "Generated Query #{Time.current.to_i}"
    )

    @view_id = res.body["id"]

    respond_to do |format|
      format.turbo_stream
    end
  end

  def execute_query
    begin
      # Assuming you have DuckDB connection configured
      result = ActiveRecord::Base.connection.execute(@view_definition.duck_db_query)
      @query_result = result.to_a
      @error = nil
    rescue StandardError => e
      @error = e.message
      @query_result = nil
    end

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def set_view_definition
    @view_definition = session_scoped_resource(ViewDefinition).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to session_root_path, alert: "View definition not found"
  end

  def set_view_definition_by_view_definition_id
    @view_definition = session_scoped_resource(ViewDefinition).find(params[:view_definition_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to session_root_path, alert: "View definition not found"
  end

  def view_definition_params
    params.require(:view_definition)
  end

  def altered_params
    view_definition_params.merge!(
      name: JSON.parse(view_definition_params[:content]).fetch("name")
    )
  end
end
