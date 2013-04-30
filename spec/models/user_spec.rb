require 'spec_helper'

describe User do
  before do
    @user = FactoryGirl.create :user
  end

  it "should be valid" do
    @user.valid?.should be_true
  end

  describe "#subscribed?" do
    it "should return false when a user has no subscriptions" do
      @user.subscriptions.count.should == 0
      @user.subscribed?.should == false
    end
    
    it "should return false when a user has no active subscriptions" do
      FactoryGirl.create :subscription, :status => "inactive", :user => @user
      @user.subscriptions.count.should == 1
      @user.subscribed?.should == false
    end
    
    it "should return true when a user has an active subscription" do
      FactoryGirl.create :subscription, :status => "inactive", :user => @user
      FactoryGirl.create :subscription, :status => "inactive", :user => @user
      FactoryGirl.create :subscription, :status => "active", :user => @user
      @user.subscriptions.count.should == 3
      @user.subscribed?.should == true
    end
    
  end
  
  describe "#active_subscription" do
    
    before do
      @user.subscriptions.count.should == 0
    end
    
    it "should return nil if no subscriptions" do
      @user.subscriptions.should == []
      @user.active_subscription.should == nil
    end
    
    it "should return nil if no active subscriptions" do
      @inactive_subscription = FactoryGirl.create :subscription, :status => "inactive", :user => @user
      @user.active_subscription.should == nil
    end
    
    it "should return active subscription if one active and multiple inactive subscriptions" do
      FactoryGirl.create :subscription, :status => "inactive", :user => @user
      FactoryGirl.create :subscription, :status => "inactive", :user => @user
      @active_subscription = FactoryGirl.create :subscription, :status => "active", :user => @user
      
      @user.active_subscription.should == @active_subscription
    end
    
    it "should return active subscription if only one subscription and it's active" do 
      @active_subscription = FactoryGirl.create :subscription, :status => "active", :user => @user
      @user.active_subscription.should == @active_subscription
    end
  end
  
  describe "#deactivate_excess_channels!" do
    
    before do
      @plan = FactoryGirl.create :plan, channels: 2
      @user = FactoryGirl.create :user, plan: @plan
    end
    
    it "should work but do nothing if user has no channels" do
      @user.channels.size.should == 0
      @user.deactivate_excess_channels!
    end
    
    it "should do nothing if a user has the same number of running channels as the plan limit" do
      FactoryGirl.create :channel, user: @user, running: true
      FactoryGirl.create :channel, user: @user, running: true
      @user.channels.running.size.should == 2
      
      @user.deactivate_excess_channels!
      
      @user.reload.channels.running.size.should == 2
    end
    
    it "should do nothing if a user has fewer running channels than the plan limit" do
      FactoryGirl.create :channel, user: @user, running: true
      @user.channels.running.size.should == 1
      
      @user.deactivate_excess_channels!
      
      @user.reload.channels.running.size.should == 1
    end
    
    it "should de-activate channels to comply with plan limit" do
      FactoryGirl.create :channel, user: @user, running: true
      FactoryGirl.create :channel, user: @user, running: true
      FactoryGirl.create :channel, user: @user, running: true
      @user.channels.running.size.should == 3
      
      @user.deactivate_excess_channels!
      
      @user.reload.channels.running.size.should == 2
      @user.reload.channels.size.should == 3
    end
    
    it "should de-activate older channels" do
      @oldest = FactoryGirl.create :channel, user: @user, running: true
      FactoryGirl.create :channel, user: @user, running: true
      FactoryGirl.create :channel, user: @user, running: true
      
      @user.channels.running.size.should == 3
      
      @user.deactivate_excess_channels!
      
      @oldest.reload.should_not be_running
    end
    
    it "should not restrict super admins" do
      FactoryGirl.create :channel, user: @user, running: true
      FactoryGirl.create :channel, user: @user, running: true
      FactoryGirl.create :channel, user: @user, running: true
      
      @user.super_admin = true
      @user.save!
      
      @user.deactivate_excess_channels!
      
      @user.reload.channels.running.size.should == 3
    end
  end

end
