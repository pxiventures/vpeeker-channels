class SubscriptionsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  before_filter :verify_fastspring_hash

  # Internal: Callback from Fastspring when a subscription has been activated.
  # This means that payment has gone through and the user has a valid, active
  # subscription with us.
  #
  # We create a Subscription for them, and set their plan, based on the details
  # in the callback parameters.
  def activate
    
    # Subscription vitals
    customer_ref = params[:SubscriptionReferrer]
    plan_ref = params[:ProductPath].sub("/", "")
    subscription_ref = params[:SubscriptionReference]
    
    # subscription info
    status = params[:SubscriptionStatus].to_s.downcase.strip
    end_date = params[:SubscriptionEndDate]
    next_period_date = params[:SubscriptionNextPeriodDate]
    status_reason = params[:SubscriptionStatusReason]
    total_price = params[:SubscriptionTotalPriceValue]
    
    user = User.find(customer_ref)
    plan = Plan.find_by_fastspring_reference(plan_ref)
    
    raise "Received subscription activation but the subscription status is not 'active', but is rather: '#{status}'" unless status == "active"
    raise "Received subscription activation for #{user.id} but couldn't find a matching plan: #{plan_ref}" unless plan
    raise "Received subscription activation for #{user.id} but they already have an active subscription with reference #{user.active_subscription.reference}" if user.subscribed?

    Subscription.create!(
      user: user,
      reference: subscription_ref,
      end_date: end_date,
      next_period_date: next_period_date,
      status: status,
      status_reason: status_reason,
      total_price: total_price,
      currency: params[:SubscriptionTotalPriceCurrency]
    )
    user.plan = plan
    user.save!

    render nothing: true, status: 200
  end

  # received from Fastspring at the moment the subscription has run out
  def deactivate
    customer_ref = params[:SubscriptionReferrer]
    subscription_ref = params[:SubscriptionReference]
    status = params[:SubscriptionStatus].to_s.downcase.strip

    user = User.find(customer_ref)
    
    subscription = user.active_subscription
    raise "Received subscription deactivation for #{user.id} but the active subscription (#{subscription.reference}) doesn't match the notification (#{subscription_ref})" unless subscription.reference == subscription_ref
    
    # set the new status
    subscription.status = status
    subscription.save!
    
    # move to default plan
    user.plan = Plan.default_plan
    user.save!
    
    # de-activate all channels
    user.deactivate_excess_channels!
    
    render nothing: true, status: 200
  end

  # notification of subscription upgrade, downgrade or cancellation
  def changed
    customer_ref = params[:SubscriptionReferrer]
    plan_ref = params[:ProductPath].sub("/", "")
    subscription_ref = params[:SubscriptionReference]
    
    # subscription info
    end_date = params[:SubscriptionEndDate]
    next_period_date = params[:SubscriptionNextPeriodDate]
    status = params[:SubscriptionStatus].downcase.strip
    status_reason = params[:SubscriptionStatusReason]
    total_price = params[:SubscriptionTotalPriceValue]
    currency = params[:SubscriptionTotalPriceCurrency]

    user = User.find(customer_ref)
    raise "Received subscription changed for #{user.id} but they don't have an active subscription" unless user.subscribed?
    
    subscription = user.active_subscription
    raise "Received subscription changed for #{user.id} but the active subscription (#{subscription.reference}) doesn't match the notification (#{subscription_ref})" unless subscription.reference == subscription_ref
    
    plan = Plan.find_by_fastspring_reference(plan_ref)
    raise "Received subscription changed for #{user.id} but couldn't find a matching plan: #{plan_ref}" unless plan
    
    # update subscription info, including status
    subscription.update_attributes!(
      status: status.to_s.downcase.strip,
      end_date: end_date,
      next_period_date: next_period_date,
      status_reason: status_reason,
      total_price: total_price,
      currency: currency
    )
    
    # change plan 
    user.plan = plan
    user.save!
    
    # de-activate excess channels
    user.deactivate_excess_channels!
    
    render nothing: true, status: 200
  end
  
  private
  
  def verify_fastspring_hash
    return if Rails.env == "test"

    render :status => 404, :nothing => true and return unless params[:security_data] and params[:security_hash]
    unless Digest::MD5.hexdigest(params[:security_data] + AppConfig.fastspring.private_key) == params[:security_hash]
      logger.warn "Received an invalid subscription activation message"
      render :nothing => true, :status => 404 and return
    end
  end

end
