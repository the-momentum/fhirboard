# frozen_string_literal: true

require "rack"

class Helth
  include Singleton

  class HealthCheckError < StandardError
    attr_reader :check_name, :original_error

    def initialize(check_name, original_error)
      @check_name = check_name
      @original_error = original_error
      super("Health check '#{check_name}' failed: #{original_error.message}")
    end
  end

  def self.app
    Rack::Builder.new do
      run lambda { |env|
        begin
          Helth.all_good?(env) ? [200, {}, ["OK"]] : [500, {}, ["NOK"]]
        rescue StandardError => e
          Sentry.capture_exception(e)
          [500, {}, ["NOK"]]
        end
      }
    end
  end

  def self.all_good?(env)
    failed_checks = []

    checks.each_with_index do |check_data, index|
      check_name = check_data[:name]
      check_block = check_data[:block]

      begin
        result = check_block.call(env)
        unless result
          failed_checks << "Check '#{check_name}' returned false"
        end
      rescue StandardError => e
        error = HealthCheckError.new(check_name, e)
        Sentry.capture_exception(error,
          extra: {
            check_name: check_name,
            check_index: index,
            original_error: {
              class: e.class.name,
              message: e.message,
              backtrace: e.backtrace
            }
          }
        )
        failed_checks << error
      end
    end

    if failed_checks.any?
      Sentry.capture_message("Health check failed",
        level: "error",
        extra: { failed_checks: failed_checks }
      )
      return false
    end

    true
  end

  def self.checks
    @checks ||= []
  end

  def self.add_check(name, &block)
    raise ArgumentError, "Health check block is required" unless block_given?
    raise ArgumentError, "Health check name cannot be nil" if name.nil?

    puts "Adding check: #{name}"
    checks << { name: name, block: block }
  end

  # Clear all registered health checks (useful for testing)
  def self.reset_checks!
    @checks = []
  end
end


Helth.add_check(:database) do
  ActiveRecord::Base.connection.execute("SELECT 1")
end

Helth.add_check(:redis) do
  RedisStore.current.ping == "PONG"
end
