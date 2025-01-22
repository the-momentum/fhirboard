# frozen_string_literal: true

module Superset
  module Services
    class CreateAccount < Base
      SUPERSET_ROLE_ID_GAMMA = 4
      SUPERSET_ROLE_ID_SQL_LAB = 5
      SUPERSET_PERMISSION_ID_DATABASE_ACCESS = 80

      def call
        raise "Missing session while createing the superset account" if @current_session.nil?

        login_as_admin_user
        fetch_csrf_token

        create_database_connection
        fetch_database_access_permission
        create_database_access_role
        assign_db_access_permission_to_db_access_role
        create_user

        @database_id
      end

      private

      def create_database_connection
        response = @conn.post("database/") do |req|
          req.headers["Authorization"] = "Bearer #{@auth_token}"
          req.headers["x-csrftoken"] = @csrf_token
          req.body = {
            allow_dml:            true,
            configuration_method: "sqlalchemy_form",
            database_name:        @current_session.token,
            sqlalchemy_uri:       "duckdb:////app/datasources/#{@current_session.token}.duckdb"
          }
        end
        raise "Failed to create Superset database: #{response.body}" unless response.success?

        @database_id = response.body["id"]
      end

      def fetch_database_access_permission
        page = 0
        page_size = 10
        database_access_permission = nil
        has_more_data = true

        while has_more_data
          query_params = {
            q: "(order_column:id,order_direction:desc,page_size:#{page_size},page:#{page},filters:!((col:permission,opr:rel_o_m,value:#{SUPERSET_PERMISSION_ID_DATABASE_ACCESS})))"
          }

          response = @conn.get("security/permissions-resources/") do |req|
            req.headers["Authorization"] = "Bearer #{@auth_token}"
            req.headers["x-csrftoken"] = @csrf_token
            req.params = query_params
          end

          raise "Error while fetching Superset database access permissions: #{response.body}" unless response.success?

          database_access_permission = response.body["result"].find do |record|
            record.dig("view_menu", "name").to_s.include?(@current_session.token)
          end

          break if database_access_permission.present?

          has_more_data = data["result"].length == page_size
          page += 1
        end

        @database_access_permission_id = database_access_permission["id"]
        raise "Superset database access permission for database #{@current_session.token} not found." if @database_access_permission_id.blank?
      end

      def create_database_access_role
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
      end

      def assign_db_access_permission_to_db_access_role
        response = @conn.post("security/roles/#{@database_access_role_id}/permissions") do |req|
          req.headers["Authorization"] = "Bearer #{@auth_token}"
          req.headers["x-csrftoken"] = @csrf_token
          req.body = {
            permission_view_menu_ids: [@database_access_permission_id]
          }
        end
        raise "Failed to assign Superset permission #{permission_name} to Superset role #{role_name}." unless response.success?
      end

      def create_user
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
            roles:      [
              SUPERSET_ROLE_ID_GAMMA,
              SUPERSET_ROLE_ID_SQL_LAB,
              @database_access_role_id
            ]
          }
        end

        raise "Failed to create Superset user: #{response.body}" unless response.success?
      end
    end
  end
end
