# frozen_string_literal: true

class Policy
  class << self
    def authorize(user, resource, action)
      new(user, resource).send(:"#{action}?")
    end
  end

  def initialize(user, resource)
    @user = user
    @resource = resource
  end

  private

  attr_reader :user, :resource
end
