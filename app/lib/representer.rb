# frozen_string_literal: true

class Representer
  class << self
    def represent_with(*properties)
      @properties = properties
    end

    def one(resource, current_user = nil)
      new(resource, current_user).map(properties)
    end

    def all(resources, current_user = nil)
      resources.map { |resource| one(resource, current_user) }
    end

    private

    attr_reader :properties
  end

  def map(properties)
    return unless resource

    properties.index_with { |property| send(property) }
  end

  private

  attr_reader :resource, :current_user

  def initialize(resource, current_user = nil)
    @resource     = resource
    @current_user = current_user
  end

  def method_missing(method_name, ...)
    return super unless resource.respond_to?(method_name)

    resource.send(method_name, ...)
  end

  def respond_to_missing?(method_name, include_private = false)
    super
  end

  def represent_enum(resource, enum)
    {
      value: resource.public_send(enum),
      label: resource.class.human_attribute_name(enum_translation_key(resource, enum))
    }
  end

  def enum_translation_key(resource, enum)
    "#{enum}.#{resource.public_send(enum)}"
  end
end
