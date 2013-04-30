require 'spec_helper'

describe Channel do

  before do
    @channel = FactoryGirl.build :channel
    @channel.user.plan.channels.should > 0
  end

  it "should be valid" do
    @channel.should be_valid
  end

  describe "setting custom CSS based on the user's plan" do

    it "should set the custom CSS to blank when saved if the user isn't allowed to brand" do
      @channel.user.plan = FactoryGirl.build :plan, branding: false
      @channel.custom_css = "test"
      @channel.save
      @channel.reload.custom_css.should be_blank
    end

    it "should retain the custom CSS when the user is allowed to brand" do
      @channel.user.plan = FactoryGirl.build :plan, branding: true
      @channel.custom_css = "test"
      @channel.save
      @channel.reload.custom_css.should eq("test")
    end
  end
  
  describe "running" do
    
    before do
      @plan = FactoryGirl.create :plan, channels: 1
      @user = FactoryGirl.create :user, plan: @plan
      @user.channels.running.count.should == 0
      @user.plan.channels.should == 1
    end
    
    it "should be allowed if user has not exceeded channel usage" do
      @channel = FactoryGirl.create :channel, user: @user, running: true
      @user.reload.channels.running.count.should == 1
    end
    
    it "should prevent setting not-running channel to running" do
      c1 = FactoryGirl.create :channel, user: @user, running: true
      c2 = FactoryGirl.create :channel, user: @user, running: false
      @user.reload.channels.running.count.should == 1
      
      c2.running = true
      c2.save.should == false
      
      @user.reload.channels.running.count.should == 1
    end
    
    it "should set running to false when not allowed to be true" do
      c1 = FactoryGirl.create :channel, user: @user, running: true
      c2 = FactoryGirl.create :channel, user: @user, running: false
      
      c2.running = true
      c2.save
      c2.running.should == false
    end
    
    it "should present appropriate error messages on model" do
      c1 = FactoryGirl.create :channel, user: @user, running: true
      c2 = FactoryGirl.create :channel, user: @user, running: false
      c2.running = true
      c2.save
      c2.errors.messages[:running].first.should match(/not allowed because your channel limit is . but you already have . running./)
    end
    
  end

end
