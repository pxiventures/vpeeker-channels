require 'spec_helper'

describe Subscription do
  describe "active scope" do
    
    it "should return empty array when there are no subscriptions" do
      Subscription.count.should == 0
      Subscription.active.should == []
    end
    
    it "should return empty array when there are no active subscriptions" do
      FactoryGirl.create :subscription, :status => "inactive"
      FactoryGirl.create :subscription, :status => "inactive"
      Subscription.active.should == []
    end
    
    it "should return active subscriptions" do
      @inactive_subscription = FactoryGirl.create :subscription, :status => "inactive"
      @active_subscription = FactoryGirl.create :subscription, :status => "active"
      subscriptions = Subscription.active
      subscriptions.should_not include(@inactive_subscription)
      subscriptions.should include(@active_subscription)
    end
    
  end
end
