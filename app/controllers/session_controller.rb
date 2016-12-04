class SessionController < ApplicationController

  before_action :create_authenticator, only: [:new, :create]

  def new

    if request.referrer.present?
      session[:referrer] = request.referrer
    end

    redirect_to @authenticator.authorization_url
  end

  def create

    if params[:code].present?
      email = @authenticator.get_email(params[:code])

      user = User.find_or_create_by!(email: email)
      user_session = user.sessions.create!

      cookies[:session_id] = user_session.id
    end

    redirect_to session.delete(:referrer) || root_path
  end

  def destroy
    current_session&.destroy
  end

  private

    def create_authenticator
      @authenticator = GoogleAuthenticator.new(callback_url: session_url)
    end
end
