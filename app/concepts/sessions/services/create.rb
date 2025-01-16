# frozen_string_literal: true

module Sessions
  module Services
    class Create
      def call
        session = Session.create!
        assign_sample_analyses(session)
        session
      end

      private

      def create_session
        Session.create!
      end

      def assign_sample_analyses(session)
        sample_analyses.each do |analysis|
          duplicate_analysis_for_session(analysis, session)
        end
      end

      def sample_analyses
        Analysis.includes(:view_definitions).where(sample: true)
      end

      def duplicate_analysis_for_session(analysis, session)
        new_analysis = analysis.dup.tap do |new_analysis|
          new_analysis.session = session
          new_analysis.sample = false
          new_analysis.save!
        end

        analysis.view_definitions.each do |view_definition|
          new_view_definition = view_definition.dup
          new_view_definition.analysis = new_analysis
          new_view_definition.session = session
          new_view_definition.save!
        end

        new_analysis
      end
    end
  end
end
