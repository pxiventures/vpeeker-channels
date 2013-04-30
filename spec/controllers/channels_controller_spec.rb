require 'spec_helper'

describe ChannelsController do


  describe "#embed" do

    it "should return success for channels made by users with plans that support embed" do
      plan = FactoryGirl.create :plan, embed: true
      user = FactoryGirl.create :user, plan: plan
      channel = FactoryGirl.create :channel, user: user
      request.host = "#{channel.subdomain}.example.com"
      get :embed
      response.status.should eq(200)
    end

    it "should return forbidden for channels made by users with plans that don't support embed" do
      plan = FactoryGirl.create :plan, embed: false
      user = FactoryGirl.create :user, plan: plan
      channel = FactoryGirl.create :channel, user: user
      request.host = "#{channel.subdomain}.example.com"
      get :embed
      response.status.should eq(400)
    end


  end

end
