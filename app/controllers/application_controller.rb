class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout proc { false if request.xhr? }

  protected

    def current_session

      if @current_session.nil? and cookies.has_key? :session_id
        @current_session = Session.find_by(cookies[:session_id])
      end

      @current_session
    end
end
