class ExportController < ApplicationController
  before_filter :basic_auth unless Rails.env =~ /development/
  
  def subscription_summary
    data = Subscription.joins(:user => :plan).select("plans.name, count(distinct subscriptions.id)").group("plans.name")
    render json: data
  end
  
  def seven_day_active_percentage
    active = User.joins(:plan).where(
      "plans.subscribable = ? and users.last_sign_in_at >= ?", true, Time.now-7.days
    ).count
    
    total = User.joins(:plan).where("plans.subscribable = ?", true).count
    
    if total == 0
      render json: {value: 0}
    else
      render json: {value: active/total.to_f.round(4)}
    end
  end
  
  def warm_conversion_opportunities
    total = User.joins(:plan).where(
      "plans.subscribable = ? and users.last_sign_in_at >= ?", false, Time.now-7.days
    ).count
    
    render json: {count: total}
  end
  
  def channel_summary
    count_all = Channel.count
    
    count_running = Channel.running.count
    
    #active channels have been visited within the activity threshold and have > 0 videos
    count_active = Channel.joins(:videos).select("distinct channels.id").where("last_visited_at >= ?", AppConfig.channels.activity_threshold.ago).group("channels.id").having("count(videos.id) > 0").all.size
    
    count_new = Channel.where("created_at >= ?", 7.days.ago).count
    
    # channels in an error state have a last search status of something other than "OK!"
    count_error = Channel.where("last_search_status <> 'OK!'").count
    
    render json: {
      all: count_all,
      running: count_running,
      active: count_active,
      new: count_new,
      error: count_error
    }
  end
  
  protected
  
  def basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      username == AppConfig.export.username && password == AppConfig.export.password
    end
  end
  
end
