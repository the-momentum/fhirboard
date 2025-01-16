# frozen_string_literal: true

class StaticPagesController < ApplicationController
  include SessionManagement

  skip_before_action :set_session
  before_action :set_or_create_session, only: %i[index]

  def index

  end
end
