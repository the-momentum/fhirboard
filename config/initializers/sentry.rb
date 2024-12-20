# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = Rails.application.credentials[:sentry_dsn]
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # To activate performance monitoring, set one of these options.
  # We recommend adjusting the value in production:
  config.traces_sample_rate   = 0.2
  config.enabled_environments = %w[production staging]
  config.release              = ENV.fetch("RELEASE_NAME", nil)

  config.excluded_exceptions.delete("ActiveRecord::RecordNotFound")
end
