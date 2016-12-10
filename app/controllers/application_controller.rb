class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout proc { false if request.xhr? }

  helper_method :current_session
  helper_method :signed_in?
  
  protected
  
    def current_session

      if @current_session.nil? && cookies.has_key?(:session_id)
        @current_session = Session.includes(:user).find_by(cookies[:session_id])
      end

      @current_session
    end

    def signed_in?
      current_session.present?
    end
end
