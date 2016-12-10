class SessionsController < ApplicationController

  def new
    if request.referrer.present?
      session[:referrer] = request.referrer
    end

    redirect_to authenticator.authorization_url
  end

  def oauth2_callback
    if params[:code].present?
      email = authenticator.get_email(params[:code])

      user = User.find_or_create_by!(email: email)
      user_session = user.sessions.create!

      cookies[:session_id] = user_session.id
    end

    redirect_to (session.delete(:referrer) or root_path)
  end

  def destroy
    current_session&.destroy!
    cookies.delete(:session_id)

    redirect_to root_path
  end

  private

    def authenticator
      
      @authenticator ||= GoogleAuthenticator.new(
          callback_url: oauth2_callback_url
      )
    end
end
