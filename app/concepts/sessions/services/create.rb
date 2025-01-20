# frozen_string_literal: true

module Sessions
  module Services
    class Create
      def call
        Session.transaction do
          session = Session.create!
          assign_sample_analyses(session)
          create_superset_user(session)
          create_duckdb_database(session)
          create_superset_database_connection(session)
          session
        end
      end

      private

      def create_session
        Session.create!
      end

      def assign_sample_analyses(session)
        sample_analyses.each_slice(100) do |analyses_batch|
          new_analyses = []
          new_view_definitions = []

          analyses_batch.each do |analysis|
            new_analysis = build_duplicated_analysis(analysis, session)
            new_analyses << new_analysis

            analysis.view_definitions.each do |view_definition|
              new_view_definitions << build_duplicated_view_definition(
                view_definition,
                new_analysis,
                session
              )
            end
          end

          Analysis.import(new_analyses)
          ViewDefinition.import(new_view_definitions)
        end
      end

      def create_superset_user(session)
        Superset::Services::ApiService.new(current_session: session).create_user
      end

      def create_duckdb_database(session)
        Utils::Services::InitializeDuckdbDatabase.new(current_session: session).call
      end

      def create_superset_database_connection(session)
        api_service = Superset::Services::ApiService.new(current_session: session)
        response = api_service.create_database_connection

        raise "Failed to create Superset database: #{response.body}" unless response.success?

        database_id = response.body["id"]
        session.update(superset_db_connection_id: database_id)
      end

      def sample_analyses
        Analysis.includes(:view_definitions).where(sample: true)
      end

      def build_duplicated_analysis(analysis, session)
        analysis.dup.tap do |new_analysis|
          new_analysis.session = session
          new_analysis.sample = false
        end
      end

      def build_duplicated_view_definition(view_definition, analysis, session)
        view_definition.dup.tap do |new_view_definition|
          new_view_definition.analysis = analysis
          new_view_definition.session = session
        end
      end
    end
  end
end
