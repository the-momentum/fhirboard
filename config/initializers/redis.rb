# frozen_string_literal: true

module RedisStore
  def self.current
    @current ||= Redis.new(Rails.configuration.redis)
  end
end
