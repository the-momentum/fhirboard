# frozen_string_literal: true

require "dry/monads"

class Monads
  include Dry::Monads[:result, :do]
  include Validations

  private

  def params_for(*params_path)
    param = validated_params.dig(*params_path)

    if param == false
      false
    else
      param.presence
    end
  end
end
