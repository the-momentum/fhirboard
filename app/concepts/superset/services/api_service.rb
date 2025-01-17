# frozen_string_literal: true

# app/concepts/superset/services/api_service.rb
module Superset
  module Services
    class ApiService
      SUPERSET_BASE_URL = "#{ENV['SUPERSET_INTERNAL_URL']}/api/v1/"
      SUPERSET_ADMIN_ROLE_ID = 1

      def initialize(current_session: nil)
        @current_session = current_session
        @conn = Faraday.new(url: "http://superset:8088/api/v1/") do |f|
          f.request :json
          f.response :json
          f.response :logger
          f.use :cookie_jar
        end
        @auth_token = nil
        @csrf_token = nil
      end

      def login
        return unless @current_session

        response = @conn.post("security/login") do |req|
          req.body = {
            username: @current_session.superset_username,
            password: @current_session.superset_password,
            provider: "db",
            refresh:  true
          }
        end
        @auth_token = response.body["access_token"]
      end

      def login_as_admin_user
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
        login_as_admin_user
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

      def create_user
        login_as_admin_user
        get_csrf_token
    
        response = @conn.post("security/users/") do |req|
          req.headers["Authorization"] = "Bearer #{@auth_token}"
          req.headers["x-csrftoken"] = @csrf_token
          req.body = {
            first_name: "fhirboard",
            last_name:  "user",
            email:      @current_session.superset_email,
            username:   @current_session.superset_username,
            password:   @current_session.superset_password,
            active:     true,
            roles:      [SUPERSET_ADMIN_ROLE_ID]
          }
        end
      end
    end
  end
end
