class Subscription < ActiveRecord::Base
  include Extensions::Adminable
  belongs_to :user

  validates :user_id, presence: true
  validates :reference, presence: true, uniqueness: true

  attr_accessible :reference, :user, :end_date, :next_period_date, :status,
    :status_reason, :total_price, :currency

  before_destroy :set_user_to_default_plan
  
  scope :active, where(:status => "active")

  # Public: Generate a subscription referrer for Fastspring.
  #
  # Remember the user can theoretically edit this in the querystring for the
  # URL.
  def self.referrer(user)
    "#{user.id}"
  end
  
  # Public: Cancel the subscription.
  #
  # Returns a <FsprgSubscription> object.
  def cancel!
    $fastspring.cancel_subscription(self.reference)
  end

  # Public: Check if the subscription is cancelable or not.
  def cancelable
    @cancelable ||= (get_subscription.cancelable == "true" ? true : false)
  end
  
  # Public: Change the subscription to a new plan
  #
  # plan: new plan to change to
  #
  # Returns something Fastspring-y
  def change_plan(plan)
    update = FsprgSubscriptionUpdate.new self.reference
    update.product_path = "/#{plan.fastspring_reference}"
    update.proration = AppConfig.fastspring.proration
    $fastspring.update_subscription update
  end

  # Public: Get the subscription data from Fastspring.
  #
  # Where possible, use the methods above to get proper data.
  def get_subscription
    @fastspring_data ||= $fastspring.get_subscription(self.reference)
  end

  delegate :customer_url, :to => :get_subscription

  private
  
  def set_user_to_default_plan
    self.user.plan = Plan.default_plan
    self.user.save
  end


end
