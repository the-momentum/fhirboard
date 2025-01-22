# frozen_string_literal: true

module ApplicationHelper
  def session_analyses
    @session_analyses ||= Analysis.where(session_id: current_session.id)
  end
end
