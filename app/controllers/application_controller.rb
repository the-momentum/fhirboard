class ApplicationController < ActionController::Base
  include Dry::Monads[:result]
  include SessionManagement
end
