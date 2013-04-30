require 'spec_helper'

describe OmniauthCallbacksController do

  before do
    @uid = "uid"
    request.env["devise.mapping"] = Devise.mappings[:user] 
    request.env["omniauth.auth"] = mock_omniauth(@uid)
  end

  describe "GET all" do
    it "should set the first user to be an admin" do
      get :twitter
      # We prompt for an email, annoyingly.
      session["devise.user_attributes"]["super_admin"].should be_true
    end
  end
end

