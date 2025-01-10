# frozen_string_literal: true

# app/concepts/superset/services/api_service.rb
module Superset
  module Services
    class ApiService
      def initialize
        @conn = Faraday.new(url: "#{ENV['SUPERSET_URL']}/api/v1/") do |f|
          f.request :json
          f.response :json
          f.response :logger
          f.use :cookie_jar
        end
        @auth_token = nil
        @csrf_token = nil
      end

      def login
        response = @conn.post("security/login") do |req|
          req.body = {
            username: ENV['SUPERSET_ADMIN_USERNAME'],
            password: ENV['SUPERSET_ADMIN_PASSWORD'],
            provider: "db",
            refresh:  true
          }
        end
        @auth_token = response.body["access_token"]
      end

      def get_csrf_token
        response = @conn.get("security/csrf_token/") do |req|
          req.headers["Authorization"] = "Bearer #{@auth_token}"
        end

        @csrf_token = response.body["result"]
      end

      def save_query(sql, label)
        unless Setting.get("superset_duckdb_database_id")
          raise "Database ID not found in settings. Please create it first."
        end

        login
        get_csrf_token

        @conn.post("saved_query/") do |req|
          req.headers["Authorization"] = "Bearer #{@auth_token}"
          req.headers["x-csrftoken"] = @csrf_token
          req.body = {
            label:       label,
            sql:         sql,
            db_id: Setting.get("superset_duckdb_database_id")
          }
        end
      end

      def create_database(name)
        login
        get_csrf_token

        @conn.post("database/") do |req|
          req.headers["Authorization"] = "Bearer #{@auth_token}"
          req.headers["x-csrftoken"] = @csrf_token
          req.body = {
            allow_dml:            true,
            configuration_method: "sqlalchemy_form",
            database_name:        name,
            sqlalchemy_uri:       "duckdb:////app/fhir-export/#{name}.duckdb"
          }
        end
      end
    end
  end
end
