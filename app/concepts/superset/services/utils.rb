# frozen_string_literal: true

module Superset
  module Services
    class Utils < Base
      def save_query(sql, label)
        duckdb_database_id = @current_session&.superset_db_connection_id
        raise "Database ID not found in settings. Please create it first." unless duckdb_database_id

        login
        fetch_csrf_token

        @conn.post("saved_query/") do |req|
          req.headers["Authorization"] = "Bearer #{@auth_token}"
          req.headers["x-csrftoken"] = @csrf_token
          req.body = {
            label: label,
            sql:   sql,
            db_id: duckdb_database_id
          }
        end
      end
    end
  end
end
