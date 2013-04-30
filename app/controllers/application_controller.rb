class ApplicationController < ActionController::Base
  protect_from_forgery
  layout :layout_by_resource

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to main_app.root_url, alert: "Not authorized"
  end

  protected

  def layout_by_resource
    if devise_controller? && resource_name == :user
      "admin"
    else
      "application"
    end
  end
end
