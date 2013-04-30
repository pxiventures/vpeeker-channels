class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def all
    auth = request.env["omniauth.auth"]
    user = User.from_omniauth(auth)

    user.super_admin = true if User.count == 0

    if user.persisted?
      flash.notice = "Signed in"
      sign_in_and_redirect user
    else
      session["devise.user_attributes"] = user.attributes
      redirect_to new_user_registration_url
    end
  end

  alias_method :twitter, :all
end
