# frozen_string_literal: true

Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.base_controller_class = ["ActionController::API", "ActionController::Base"]
  config.lograge.custom_options = lambda do |event|
    options = event.payload.slice(:request_id, :user_id)
    options[:params] = event.payload[:params]&.except("controller", "action") || {}
    options[:time] = event.time
    options
  end
end
