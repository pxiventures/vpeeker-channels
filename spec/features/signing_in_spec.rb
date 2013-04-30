require 'spec_helper'

describe "Signing in" do

  before do
    @uid = "test"
    mock_omniauth(@uid)
  end

  it "should make the first user an admin" do
    visit root_path
    click_link "with Twitter"

    within("#new_user") do
      fill_in "Email", with: "test@example.com"
      click_button "Sign up"
    end

    User.find_by_uid(@uid).super_admin.should be_true
  end

end


