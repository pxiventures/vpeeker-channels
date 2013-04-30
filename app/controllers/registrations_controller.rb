class RegistrationsController < Devise::RegistrationsController
  before_filter :load_plans, only: [:edit, :update]
  before_filter :load_subscription, only: [:edit, :update]

  # Profile page
  def edit
    super
  end

  def update
    if params.has_key? :cancel
      begin
        @cancelSub = current_user.active_subscription.cancel!
        logger.info @cancelSub.inspect
        redirect_to edit_user_registration_path, notice: "Subscription cancelled successfully. It may take a moment for this to be reflected here."
      rescue FsprgException => e
        redirect_to edit_user_registration_path, alert: e.error_body
      end
    elsif params.has_key? :update
      begin
        plan = Plan.find params[:plan_id]
        @changePlan = current_user.active_subscription.change_plan(plan)
        logger.info @changePlan.inspect
        redirect_to edit_user_registration_path, notice: "Subscription plan changed successfully. It may take a moment for this to be reflected here."
      rescue FsprgException => e
        redirect_to edit_user_registration_path, alert: e.error_body
      rescue ActiveRecord::RecordNotFound => e
        redirect_to edit_user_registration_path, alert: "Plan not found."
      end
    else
      super
    end
  end

  private
  def load_plans
    @plans = Plan.subscribable
  end

  def load_subscription
    @subscription = current_user.active_subscription
  end

end
