# # frozen_string_literal: true

# require "sidekiq"
# require "sidekiq/web"

# Sidekiq.configure_server do |config|
#   config.redis = Rails.configuration.redis
# end

# Sidekiq.configure_client do |config|
#   config.redis = Rails.configuration.redis
# end

# schedule_file = Rails.root.join("config", "schedule.yml")

# if File.exist?(schedule_file) && %w(development test).exclude?(Rails.env)
#   file_data = YAML.load_file(schedule_file)

#   Sidekiq::Cron::Job.load_from_hash file_data

#   Sidekiq::Cron::Job.all.reject { |j| file_data.key?(j.name) }.each(&:destroy)
# end

# Sidekiq.strict_args!(:warn)
