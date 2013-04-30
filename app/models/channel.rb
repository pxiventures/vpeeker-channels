class Channel < ActiveRecord::Base
  
  has_many :videos, dependent: :destroy
  belongs_to :user
  
  include Extensions::Adminable
  
  rails_admin do 
    
    list do
      field :name
            
      field :videos do
        pretty_value do
          value.count.to_s
        end
      end
      
      field :subdomain
      field :last_search_status
      field :search
      field :video_limit
      field :interval
      field :user
    end
    
    show do
      configure :videos do
        pretty_value do
          value.count.to_s
        end
      end
    end
    
    export do
      
      configure :channel_user_plan do
        export_value do
          bindings[:object].user.plan.name
        end
      end
      
      configure :using_custom_css do
        export_value do
          !bindings[:object].custom_css.blank?
        end
      end
      
      configure :video_count do
        export_value do
          bindings[:object].videos.count.to_s
        end
      end
      
    end
  
  end
  
  scope :running, where(:running => true)
  
  attr_accessible :interval, :name, :running, :search, :default_approved_state,
    :video_limit, :custom_css, :ga_tag, :subdomain, :password, :use_password,
    :default_mute, :last_visited_at
  attr_accessor :password
  attr_accessor :use_password

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true,
    format: {with: /^[a-zA-Z0-9\-]+$/,
             message: "can only contain letters, numbers and hyphens"}
  validate :video_limit_must_be_greater_than_remembered_videos
  
  # only do this validation on update, not create, because the use-case is preventing 
  # an existing channel set running = true when it's not allowed. We're not trying to prevent adding
  # additional channels since this is handled with CanCan.
  validate :cannot_set_running_if_channel_usage_exceeded, :on => :update
  
  validates :search, presence: true

  before_save do
    self.interval ||= AppConfig.default_search_interval
    self.subdomain = self.subdomain.downcase if self.subdomain
    self.custom_css = "" if custom_css_changed? and self.user.cannot?(:brand, Channel)
    self.search = self.search.split.map{|w| w.downcase == "or" ? w.upcase : w}.join(" ")
  end

  before_save :reset_last_tweet_id_if_search_changed
  before_save :change_unmoderated_videos_if_default_state_changed
  before_save :hash_password

  # Public: Instance of a Twitter API client for this channel.
  def twitter
    @twitter ||= Twitter::Client.new(
      oauth_token: access_token,
      oauth_token_secret: access_token_secret
    )
  end

  # First try and use tokens set on the channel itself. If not, fall back to
  # the user that owns the channel. If no user owns the channel then fallback
  # to the default tokens in the config.
  def access_token
    (self[:access_token].blank? ? nil : self[:access_token]) || (self.user ? self.user.access_token : nil) || AppConfig.twitter.access_token
  end
  def access_token_secret
    (self[:access_token_secret].blank? ? nil : self[:access_token_secret]) || (self.user ? self.user.access_token_secret : nil) || AppConfig.twitter.access_token_secret
  end

  # Public: Create a hash of search options to be passed to Twitter#search.
  def search_options
    options = {results_type: "recent",
               count: 100,
               include_entities: true}
    if self.last_tweet_id
      options[:since_id] = self.last_tweet_id
    end

    return options
  end

  def perform_search
    # Update searched_at right at the start, this might take a while
    self.searched_at = Time.now
    self.save
    begin
      result = self.twitter.search(search + " vine", search_options)
    rescue Twitter::Error::ClientError => e
      logger.warn "Error communicating with Twitter for channel #{self.name}: #{e.message}"
      self.interval = e.message.include?("Rate") ? AppConfig.channels.recovery_time : AppConfig.channels.longest_interval
      self.last_search_status = e.message
    else
      puts "#{self.name} results: #{result.statuses.length}"
      self.last_search_status = "OK!"
      self.last_tweet_id = result.statuses.map(&:id).max if result.statuses.length > 0
      result.statuses.each do |tweet|
        Video.create_from_tweet!(tweet, self) if tweet.source =~ /vine/i
      end

      # Modify search interval based on number of results.
      if result.statuses.length > 1 and self.interval > AppConfig.channels.shortest_interval
        # Floor straight down if we're recovering from API errors.
        self.interval = [self.interval / 2, AppConfig.channels.longest_interval].min
      elsif result.statuses.length == 0 and self.interval < AppConfig.channels.longest_interval
        self.interval = [self.interval * 2, AppConfig.channels.longest_interval].min
      end

      trim_videos if self.video_limit
    end
    self.save
  end

  # Public: Trim the number of videos in the DB for this channel based on the
  # video limit
  def trim_videos
    return false unless self.video_limit
    self.videos.order("created_at DESC").offset(self.video_limit).destroy_all
  end

  def video_limit_must_be_greater_than_remembered_videos
    unless self.user.super_admin?
      errors.add(:video_limit, "must be greater than #{AppConfig.remember_videos}") if !self.video_limit || self.video_limit <= AppConfig.remember_videos
      errors.add(:video_limit, "must be less than #{AppConfig.max_videos}") if !self.video_limit || self.video_limit >= AppConfig.max_videos
    end
  end
  
  # only suitable for use on update of existing channels, not new instances.
  def cannot_set_running_if_channel_usage_exceeded
    # This validation should only run on the 'rising edge' of the running flag.
    if self.running_changed? and self.running?
      current_running = self.user.channels.running.count
      allowed_running = self.user.plan.channels
      
      if !self.user.super_admin? && self.running? && current_running == allowed_running
        errors.add(
          :running, 
          "not allowed because your channel limit is #{allowed_running} but you already have #{current_running} running. Please remove some of your other channels or stop them from running"
        )
        self.running = false
      end
    end
  end
  
  def reset_last_tweet_id_if_search_changed
    self.last_tweet_id = nil if self.search_changed?
  end

  def change_unmoderated_videos_if_default_state_changed
    self.videos.where(moderated: false).update_all(approved: self.default_approved_state) if self.default_approved_state_changed?
  end

  def use_password
    @use_password.nil? ? !self.password_digest.blank? : @use_password
  end

  # Public: Record that the channel has been visited.
  def visited!
    update_attributes(last_visited_at: Time.now) if !last_visited_at || last_visited_at <= AppConfig.channels.activity_threshold.ago
  end

  def recently_visited?
    last_visited_at && last_visited_at >= AppConfig.channels.activity_threshold.ago
  end

  def hash_password
    if self.use_password and !self.password.blank?
      self.password_digest = Digest::MD5.hexdigest([self.subdomain,"",self.password].join(":"))
    elsif self.password.blank? and !self.use_password
      self.password_digest = nil
    end
  end
end
