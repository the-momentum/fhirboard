# frozen_string_literal: true

if Rails.env.local?
  require "bundler/audit/cli"

  namespace :bundler do
    task audit: [:environment] do
      %w(update check).each do |command|
        Bundler::Audit::CLI.start [command]
      end
    end
  end
end
