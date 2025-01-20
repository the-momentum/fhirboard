# frozen_string_literal: true

module Sessions
  module Services
    class Create
      def call
        Session.transaction do
          @session = Session.create!
          assign_sample_analyses
          create_duckdb_database
          create_superset_account
          @session
        end
      end

      private

      def create_session
        Session.create!
      end

      def assign_sample_analyses
        sample_analyses.each_slice(100) do |analyses_batch|
          new_analyses = []
          new_view_definitions = []

          analyses_batch.each do |analysis|
            new_analysis = build_duplicated_analysis(analysis)
            new_analyses << new_analysis

            analysis.view_definitions.each do |view_definition|
              new_view_definitions << build_duplicated_view_definition(
                view_definition,
                new_analysis
              )
            end
          end

          Analysis.import(new_analyses)
          ViewDefinition.import(new_view_definitions)
        end
      end

      def sample_analyses
        Analysis.includes(:view_definitions).where(sample: true)
      end

      def build_duplicated_analysis(analysis)
        analysis.dup.tap do |new_analysis|
          new_analysis.session = @session
          new_analysis.sample = false
        end
      end

      def build_duplicated_view_definition(view_definition, analysis)
        view_definition.dup.tap do |new_view_definition|
          new_view_definition.analysis = analysis
          new_view_definition.session = @session
        end
      end

      def create_duckdb_database
        Utils::Services::InitializeDuckdbDatabase.new(current_session: @session).call
      end

      def create_superset_account
        superset_database_id = superset_account_service.call
        @session.update(superset_db_connection_id: superset_database_id)
      end

      def superset_account_service
        @superset_account_service ||= Superset::Services::CreateAccount.new(current_session: @session)
      end
    end
  end
end
