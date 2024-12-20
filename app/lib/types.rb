# frozen_string_literal: true

module Types
  include Dry::Types()

  EmailString    = Types::String.constructor { |value| value.downcase.strip }
  StrippedString = Types::String.constructor(&:strip)
end
