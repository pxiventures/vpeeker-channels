require 'spec_helper'

describe "The Frontend" do

  describe "Viewing a channel" do

    before do
      @channel = FactoryGirl.create :channel
    end

    it "should link to the curator" do
      visit channel_path(@channel)
      page.should have_link "@#{@channel.user.nickname}"
    end

    it "should have nofollow set on curator links" do
      visit channel_path(@channel)
      page.should have_css ".user-link[rel='nofollow']"
    end

  end

end
