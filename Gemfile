# frozen_string_literal: true

source "https://rubygems.org"

gem "activerecord-import"
gem "amazing_print"
gem "bcrypt"
gem "bootsnap", ">= 1.4.2", require: false
gem 'duckdb'
gem "dry-monads"
gem "dry-validation"
gem "faraday"
gem "faraday-cookie_jar"
gem "foreman"
gem "hiredis-client"
gem "importmap-rails"
gem "lograge"
gem "oj"
gem "pagy"
gem "pg"
gem "pry"
gem "pry-byebug"
gem "pry-rails"
gem "puma"
gem "rack-cors", require: "rack/cors"
gem "rails", "~> 8"
gem "redis"
gem "sentry-rails"
gem "sentry-ruby"
gem "sentry-sidekiq"
gem "sidekiq"
gem "sprockets-rails"
gem "stimulus-rails"
gem "tailwindcss-rails", "~> 3.0"
gem "turbo-rails"

group :development do
  gem "active_record_query_trace"
  gem "annotate"
  gem "better_errors"
  gem "binding_of_caller"
  gem "brakeman", require: false
  gem "bundler-audit"
  gem "database_consistency"
  gem "rails_best_practices"
  gem "rails-erd"
  gem "relaxed-rubocop"
  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "traceroute"
end

group :test do
  gem "database_cleaner"
  gem "database_cleaner-active_record"
  gem "database_cleaner-redis"
  gem "rspec_junit_formatter"
  gem "rspec-rails"
  gem "simplecov", require: false
  gem "simplecov-cobertura", require: false
  gem "timecop"
  gem "webmock"
end

group :development, :test do
  gem "listen"
  gem "shoulda-matchers"
  gem "spring"
  gem "spring-watcher-listen"
end

group :development, :test, :staging do
  gem "factory_bot"
  gem "factory_bot_rails"
  gem "faker"
end
