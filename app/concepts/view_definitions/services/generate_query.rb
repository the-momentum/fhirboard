# frozen_string_literal: true

module ViewDefinitions
  module Services
    class GenerateQuery
      class Error < StandardError; end

      TEMPLATES = {
        create_view: "lib/view_definitions/create_view_template.sql",
        query:       "lib/view_definitions/query_template.sql"
      }.freeze

      def initialize(view_definition, template_type: :query)
        @view_definition = view_definition
        @template_type   = template_type

        validate_template_type!
      end

      def call
        write_temp_file
        run_flatquack
      ensure
        cleanup_temp_file
      end

      private

      attr_reader :view_definition, :template_type

      def template_path
        TEMPLATES.fetch(template_type)
      end

      def validate_template_type!
        return if TEMPLATES.key?(template_type)

        valid_types = TEMPLATES.keys.join(", ")
        raise Error, "Invalid template type: #{template_type}. Valid types are: #{valid_types}"
      end

      def write_temp_file
        File.write(temp_file_path, view_definition.content)
      end

      def run_flatquack
        raw_result = `bunx #{command}`
        clean_query_result(raw_result)
      rescue StandardError => e
        raise Error, "Failed to generate query: #{e.message}"
      end

      # Quick workaround to remove console.log() statement from the result (*** compiling ... ***)
      # Probably there is a better way to resolve this
      def clean_query_result(result)
        result.sub(/^.*\*\*\* compiling.*\n/, "")
      end

      def cleanup_temp_file
        FileUtils.rm_f(temp_file_path)
      end

      def temp_file_path
        @temp_file_path ||= Rails.root.join("tmp", temp_file_name)
      end

      def temp_file_name
        @temp_file_name ||= "view_def_#{Time.current.to_i}.json"
      end

      def command
        @command ||= [
          "flatquack",
          "-p tmp/#{temp_file_name}",
          "-m preview",
          "-t #{template_path}",
          "--param view_name=#{view_definition.name}",
          "--param path=#{view_definition.analysis.export_path_url}"
        ].join(" ")
      end
    end
  end
end
