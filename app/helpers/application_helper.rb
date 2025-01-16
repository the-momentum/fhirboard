# frozen_string_literal: true

module ApplicationHelper
  def session_analyses
    @session_analyses ||= Analysis.where(session_id: current_session.id)
  end

  def session_link
    session_token = current_session.token
    url = root_url(session_token:)
    text = "Click here to copy the session link to return to your dashboard or share it with others."
 
 
    link_to text, url,
            class: "text-white block text-center text-lg",
            data:  {
              controller:       "clipboard",
              action:           "click->clipboard#copy",
              clipboard_target: "source"
            }
  end
end
