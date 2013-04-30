require 'spec_helper'

describe SubscriptionsController do

  describe "#activate" do

    before do
      @plan = FactoryGirl.create :plan
      @user = FactoryGirl.create :user, plan: @plan
      @params = FactoryGirl.build :activate, ProductPath: "/#{@plan.fastspring_reference}", SubscriptionReferrer: @user.id
    end

    it "should create a subscription for a user" do
      @user.active_subscription.should be_nil
      
      post :activate, @params
      
      @user.active_subscription.should be
      @user.active_subscription.reference.should == @params[:SubscriptionReference]
    end

    it "should set the plan for the user" do
      post :activate, @params
      @user.reload.plan.should eq(@plan)
    end
    
    it "should fail if no plan exists" do
      @user = FactoryGirl.create :user
      @plan = FactoryGirl.create :plan, fastspring_reference: "real-reference"
      @params = FactoryGirl.build :activate, ProductPath: "/bogus-reference", SubscriptionReferrer: @user.id
      
      expect {
        post :activate, @params
      }.to raise_error(/couldn't find a matching plan/)
    end
    
    it "should fail if the user has an active plan already" do
      post :activate, @params
      expect {
        post :activate, @params
      }.to raise_error(/already have an active subscription/)
    end
    
    it "should fail if the activation parameters don't include a valid subscription status" do
      @params[:SubscriptionStatus] = 'bogus-status'
      expect {
        post :activate, @params
      }.to raise_error(/subscription status is not 'active'/)
    end
    
    it "should save meta data" do
      
      @end_date = Date.today + 6.months
      @next_period_date = Date.today + 1.month
      
      @params = FactoryGirl.build(
        :activate, ProductPath: "/#{@plan.fastspring_reference}", SubscriptionReferrer: @user.id,
        SubscriptionEndDate: @end_date.to_s,
        SubscriptionNextPeriodDate: @next_period_date.to_s,
        SubscriptionStatusReason: "new subscription message",
      )
      post :activate, @params
      @user.reload
      
      @user.active_subscription.end_date.should == @end_date
      @user.active_subscription.next_period_date.should == @next_period_date
      @user.active_subscription.status_reason.should == "new subscription message"
      @user.active_subscription.currency.should == @params[:SubscriptionTotalPriceCurrency]
      @user.active_subscription.total_price.should == @params[:SubscriptionTotalPriceValue].to_f
    end

  end

  describe "#changed" do
    
    before do
      
      # set up a user with existing subscription
      @plan = FactoryGirl.create :plan, channels: 2
      @user = FactoryGirl.create :user, plan: @plan
      @old_params = FactoryGirl.build :activate, ProductPath: "/#{@plan.fastspring_reference}", SubscriptionReferrer: @user.id
      
      # register the subscription
      post :activate, @old_params
      
      # new plan and associated params
      @new_plan = FactoryGirl.create :plan, channels: 1
      @params = FactoryGirl.build :changed, ProductPath: "/#{@new_plan.fastspring_reference}", SubscriptionReferrer: @user.id
    end

    it "should fail if we don't have a subscription for the user" do
      # clear the plan
      @user.subscriptions.delete_all
      
      expect {
        post :changed, @params
      }.to raise_error(/they don't have an active subscription/)
    end
    
    it "should fail if the subscription doesn't match" do
      @params[:SubscriptionReference] = "bogus-subscription-reference"
      expect {
        post :changed, @params
      }.to raise_error(/but the active subscription.*doesn't match the notification/)
    end
    
    it "should fail if no plan exists" do
      @params = FactoryGirl.build :changed, ProductPath: "/bogus-product-ref", SubscriptionReferrer: @user.id
      
      expect {
        post :changed, @params
      }.to raise_error(/couldn't find a matching plan/)
    end

    it "should change the user's plan" do
      post :changed, @params
      @user.reload.plan.should == @new_plan
    end
    
    it "should set new meta data" do
      @end_date = Date.today + 12.months
      @next_period_date = Date.today + 2.months
    
      @params[:SubscriptionEndDate] = @end_date.to_s
      @params[:SubscriptionNextPeriodDate] = @next_period_date.to_s
      @params[:SubscriptionStatusReason] = "subscription changed message"
      @params[:SubscriptionTotalPriceCurrency] = "USD"
      @params[:SubscriptionTotalPriceValue] = "10.0"
      
      post :changed, @params
      @user.reload
      
      @user.active_subscription.end_date.should == @end_date
      @user.active_subscription.next_period_date.should == @next_period_date
      @user.active_subscription.status_reason.should == "subscription changed message"
      @user.active_subscription.currency.should == @params[:SubscriptionTotalPriceCurrency]
      @user.active_subscription.total_price.should == @params[:SubscriptionTotalPriceValue].to_f
    end
    
    describe "moving to a lower plan" do
      
      before do
        FactoryGirl.create :channel, user: @user, running: true
        FactoryGirl.create :channel, user: @user, running: true
        @user.channels.running.count.should == 2
        @user.plan.channels.should == 2
      end
      
      it "should de-activate excess running channels" do
        @new_plan = FactoryGirl.create :plan, channels: 1
        @params = FactoryGirl.build :changed, ProductPath: "/#{@new_plan.fastspring_reference}", SubscriptionReferrer: @user.id
        
        post :changed, @params
        
        @user.reload.channels.running.count.should == 1
      end
      
    end
    
    describe "moving to a higher plan" do
      
      before do
        @c1 = FactoryGirl.create :channel, user: @user, running: true
        @c2 = FactoryGirl.create :channel, user: @user, running: true
        @user.channels.running.count.should == 2
        @user.plan.channels.should == 2
      end
      
      it "should not affect running channels" do
        @new_plan = FactoryGirl.create :plan, channels: 4
        @params = FactoryGirl.build :changed, ProductPath: "/#{@new_plan.fastspring_reference}", SubscriptionReferrer: @user.id
        
        post :changed, @params
        
        @user.reload.channels.running.count.should == 2
        @user.reload.channels.running.should include(@c1, @c2)
      end
      
    end
    
    
  end

  describe "#deactivate" do
    
    before do
      # set up a user with existing subscription
      @user = FactoryGirl.create :user
      @plan = FactoryGirl.create :plan
      @old_params = FactoryGirl.build :activate, ProductPath: "/#{@plan.fastspring_reference}", SubscriptionReferrer: @user.id
      
      # register the subscription
      post :activate, @old_params
      
      @params = FactoryGirl.build :deactivated, SubscriptionReferrer: @user.id
    end
    
    it "should fail if the subscription doesn't match" do
      @params[:SubscriptionReference] = "bogus-subscription-reference"
      expect {
        post :deactivate, @params
      }.to raise_error(/but the active subscription.*doesn't match the notification/)
    end
    

    it "should delete the user's subscription" do
      @user.should be_subscribed
      post :deactivate, @params
      @user.reload.should_not be_subscribed
      @user.plan.should == Plan.default_plan
    end
    
    it "should de-activate all running channels" do
      FactoryGirl.create :channel, user: @user, running: true
      @user.channels.running.count.should > 0
      
      post :deactivate, @params
      
      @user.reload.channels.running.count.should == 0
    end

  end
  
  describe "multiple subscriptions" do
    it "should be possible to create a subscription, deactivate it and re-subscribe" do
      @user = FactoryGirl.create :user
      @plan = FactoryGirl.create :plan
      @params = FactoryGirl.build :activate, ProductPath: "/#{@plan.fastspring_reference}", SubscriptionReferrer: @user.id
      
      post :activate, @params
      
      @user.reload.subscriptions.size.should == 1
      @user.should be_subscribed
      
      @params = FactoryGirl.build :deactivated, SubscriptionReferrer: @user.id
      post :deactivate, @params
      @user.should_not be_subscribed
      
      @params = FactoryGirl.build :activate, ProductPath: "/#{@plan.fastspring_reference}", SubscriptionReferrer: @user.id, SubscriptionReference: "new-reference"
      post :activate, @params
      @user.should be_subscribed
    end
  end

end
