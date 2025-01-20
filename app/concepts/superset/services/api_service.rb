# frozen_string_literal: true

# app/concepts/superset/services/api_service.rb
module Superset
  module Services
    class ApiService
      SUPERSET_BASE_URL = "#{ENV.fetch('SUPERSET_INTERNAL_URL', nil)}/api/v1/".freeze
      SUPERSET_ROLE_ID_GAMMA = 4
      SUPERSET_ROLE_ID_SQL_LAB = 5
      SUPERSET_PERMISSION_ID_DATABASE_ACCESS = 80

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
            username: ENV.fetch("SUPERSET_ADMIN_USERNAME", nil),
            password: ENV.fetch("SUPERSET_ADMIN_PASSWORD", nil),
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

      def create_database_connection
        login_as_admin_user
        get_csrf_token

        response = @conn.post("database/") do |req|
          req.headers["Authorization"] = "Bearer #{@auth_token}"
          req.headers["x-csrftoken"] = @csrf_token
          req.body = {
            allow_dml:            true,
            configuration_method: "sqlalchemy_form",
            database_name:        @current_session.token,
            sqlalchemy_uri:       "duckdb:////app/fhir-export/datasources/#{@current_session.token}.duckdb"
          }
        end
        raise "Failed to create Superset database: #{response.body}" unless response.success?

        @database_id = response.body["id"]
      end

      def create_database_access_role
        login_as_admin_user
        get_csrf_token

        database_access_permission = find_database_access_permission
        raise "Superset database access permission for database #{@session.token} not found." unless database_access_permission.present?

        role_name = "db_access_#{@current_session.token}"
        role_response = @conn.post("security/roles/") do |req|
          req.headers["Authorization"] = "Bearer #{@auth_token}"
          req.headers["x-csrftoken"] = @csrf_token
          req.body = {
            name: role_name,
          }
        end

        @database_access_role_id = role_response.body["id"]
        raise "Failed to create Superset role #{role_name}." unless @database_access_role_id

        role_permission_reponse = @conn.post("security/roles/#{@database_access_role_id}/permissions") do |req|
          req.headers["Authorization"] = "Bearer #{@auth_token}"
          req.headers["x-csrftoken"] = @csrf_token
          req.body = {
            permission_view_menu_ids: [database_access_permission["id"]]
          }
        end
        raise "Failed to assign Superset permission #{permission_name} to Superset role #{role_name}." unless role_permission_reponse.success?

        role_response
      end

      def find_database_access_permission
        page = 0
        page_size = 10
        database_access_permission = nil
        has_more_data = true

        while has_more_data
          query_params = {
            q: "(order_column:id,order_direction:desc,page_size:#{page_size},page:#{page},filters:!((col:permission,opr:rel_o_m,value:#{SUPERSET_PERMISSION_ID_DATABASE_ACCESS})))"
          }

          response = @conn.get("/security/permissions-resources/") do |req|
            req.headers["Authorization"] = "Bearer #{@auth_token}"
            req.headers["x-csrftoken"] = @csrf_token
            req.params = query_params
          end

          database_access_permission = response.body["result"].find do |record| 
            record.dig('view_menu', 'name').to_s.include?(@current_session.token)
          end
          
          break if database_access_permission.present?
          
          has_more_data = data["result"].length == page_size
          page += 1
        end

        database_access_permission
      end

      def create_user
        login_as_admin_user
        get_csrf_token

        @conn.post("security/users/") do |req|
          req.headers["Authorization"] = "Bearer #{@auth_token}"
          req.headers["x-csrftoken"] = @csrf_token
          req.body = {
            first_name: "fhirboard",
            last_name:  "user",
            email:      @current_session.superset_email,
            username:   @current_session.superset_username,
            password:   @current_session.superset_password,
            active:     true,
            roles:      [
              SUPERSET_ROLE_ID_GAMMA,
              SUPERSET_ROLE_ID_SQL_LAB,
              @database_access_role_id
            ]
          }
        end
      end

      def save_query(sql, label)
        duckdb_database_id = @current_session&.superset_db_connection_id
        raise "Database ID not found in settings. Please create it first." unless duckdb_database_id

        login
        get_csrf_token

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
