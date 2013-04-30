class InfoController < ApplicationController

  layout "admin"

  def landing
    @top_channels = Channel.all(limit: 5, order: "created_at DESC")
  end

  def signup
    @plans = Plan.subscribable
  end

  def terms
  end

end
