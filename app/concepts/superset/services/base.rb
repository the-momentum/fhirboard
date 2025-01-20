# frozen_string_literal: true

module Superset
  module Services
    class Base
      SUPERSET_BASE_URL = "#{ENV.fetch('SUPERSET_INTERNAL_URL', nil)}/api/v1/".freeze

      def initialize(current_session: nil)
        @current_session = current_session
        @conn = Faraday.new(url: SUPERSET_BASE_URL) do |f|
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

      def fetch_csrf_token
        response = @conn.get("security/csrf_token/") do |req|
          req.headers["Authorization"] = "Bearer #{@auth_token}"
        end

        @csrf_token = response.body["result"]
      end
    end
  end
end
