class User < ActiveRecord::Base
  include Extensions::Adminable
  devise :database_authenticatable, :registerable, :omniauthable,
         :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  validates :uid, presence: true
  validates :plan_id, presence: true
  
  has_many :channels
  belongs_to :plan
  before_destroy :cancel_subscription
  has_many :subscriptions, dependent: :destroy
  
  # Public: return the active subscription, if exists.
  def active_subscription
    self.subscriptions.active.first
  end
  
  # Public: Check if the user is subscribed or not.
  #
  # If you just check for the existence of the subscription model, you might
  # return true when the user has an inactive subscription.
  def subscribed?
    self.active_subscription.present?
  end

  # Find or create a user from an omniauth login.  If created, the user will
  # return invalid because it doesn't have an email address, so you should
  # handle + redirect to the sign up form accordingly.
  def self.from_omniauth(auth)
    user = where(auth.slice(:provider, :uid)).first_or_initialize do |user|
      user.uid = auth.uid
      user.provider = auth.provider
      user.nickname = auth.info.nickname
      user.plan = Plan.default_plan
    end
    user.nickname = auth.info.nickname
    user.access_token = auth.credentials.token
    user.access_token_secret = auth.credentials.secret
    user.save
    user
  end
  
  # De-activate excess channels based on current plan
  def deactivate_excess_channels!
    
    return if self.super_admin?
    
    channels_to_deactivate = self.channels.running.count - self.plan.channels
    
    # we don't care if the user has zero or more unused channels
    return if channels_to_deactivate <= 0
    
    # find the oldest x running channels, move them to not running, and save them
    self.channels.running.limit(channels_to_deactivate).order("created_at asc").each do |channel|
      channel.running = false
      channel.save!
    end
  end
  
  # Internal: Override the new_with_session Devise method to inject the
  # parameters for the user based on the Omniauth 
  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  def password_required?
    super && provider.blank?
  end

  def update_with_password(params, *options)
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end
  
  def ability
    @ability ||= Ability.new(self)
  end
  
  delegate :can?, :cannot?, :to => :ability

  private
  
  def cancel_subscription
    self.active_subscription.cancel! if self.subscribed?
  end

end
