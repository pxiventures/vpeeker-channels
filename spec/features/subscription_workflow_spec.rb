require 'spec_helper'

describe "Subscription Workflow" do

  before do
    @user = FactoryGirl.create :user, email: "my@email.com"
    @subscribable_plan = FactoryGirl.create :subscribable_plan
    mock_omniauth(@user.uid)
  end

  describe "When I'm a new user" do
    it "should give me the option to sign up for a plan when I visit My Account" do
      visit root_path
      click_link "with Twitter"
      click_link "My Account"

      page.should have_link "Sign up for the #{@subscribable_plan.name}"
    end
  end

end
