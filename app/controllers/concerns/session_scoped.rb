# frozen_string_literal: true

module SessionScoped
  extend ActiveSupport::Concern

  private

  def ensure_session_scoped(record)
    return if record.session_id == current_session.id
    redirect_to session_root_path, alert: "You don't have access to this resource"
  end

  def session_scoped_resource(scope)
    scope.where(session_id: current_session.id)
  end
end
