module SessionManagement
  extend ActiveSupport::Concern

  COOKIE_NAME = 'session_token'.freeze

  included do
    before_action :set_session
    helper_method :current_session, :session_root_path
    attr_reader :current_session
  end

  private

  def set_session
    @current_session = find_existing_session
    set_session_token(@current_session.token) if current_session.present?

    return redirect_to session_root_path if
      @current_session.nil? && !public_path? && html_request?
  end

  def set_or_create_session
    @current_session = find_existing_session

    if @current_session.nil?
      @current_session = create_new_session
      set_session_token(@current_session.token)
      
      redirect_to session_root_path
    else
      set_session_token(@current_session.token)
    end
  end

  def create_new_session
    Sessions::Services::Create.new.call
  end

  def find_existing_session
    token = session_token_from_params || session_token_from_cookie
    Session.find_by(token:) if token.present?
  end

  def session_token_from_params
    params[:session_token]
  end

  def session_token_from_cookie
    cookies[COOKIE_NAME]
  end

  def set_session_token(token)
    cookies[COOKIE_NAME] = {
      value: token,
      secure: Rails.env.production?,
      httponly: true,
      same_site: :strict
    }
  end

  def public_path?
    request.path.start_with?('/assets/') || 
    request.path == '/health'
  end

  def html_request?
    request.format.html?
  end

  def session_root_path
    root_path(session_token: current_session.token)
  end
end
