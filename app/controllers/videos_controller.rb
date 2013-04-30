class VideosController < ApplicationController
  before_filter :load_channel_by_subdomain
  load_and_authorize_resource :channel
  load_and_authorize_resource :video, through: :channel, except: :index

  def index
    redirect_to subdomain_channel_videos_url(subdomain: @channel.subdomain) and return if params[:channel_id]
    render :status => 404, :nothing => true and return unless @channel

    @channel.visited!

    session_key = "#{@channel.id}-videos"

    session[session_key] = [] if params[:reset]
    @videos_seen = session[session_key] ||= []

    # https://github.com/rails/rails/issues/778
    if @videos_seen.empty?
      not_in_condition = 0
    else
      not_in_condition = @videos_seen
    end

    next_video = Video.where("channel_id = ? AND id NOT IN (?) AND approved = true", @channel.id, not_in_condition).order("created_at DESC").limit(10).sample

    if next_video
      @videos_seen.unshift next_video.id
      session[session_key] = @videos_seen.first(AppConfig.remember_videos)
      render json: next_video
    else
      session[session_key] = []
      render status: 404, nothing: true
    end
  end

  def approve
    moderate_videos(params[:id], true)
  end

  def deny
    moderate_videos(params[:id], false)
  end

  private
  def moderate_videos(ids, to)
    if ids.include?(",")
      r = ids.split(",").map{|id| moderate_video(true, id)}
    else
      r = [moderate_video(true)]
    end
    if r.uniq == [true]
      redirect_to moderate_channel_path(@channel), notice: to ? "Approved" : "Denied"
    else
      redirect_to moderate_channel_path(@channel), alert: "There were some problems: #{r.to_sentence}"
    end
  end

  def moderate_video(to, id=nil)
    channel = Channel.find(params[:channel_id])
    video = channel.videos.find(id || params[:id])
    if video.update_attributes(approved: to, moderated: true)
      return true
    else
      return video.errors.full_messages.to_sentence
    end
  end

  private
  # Internal: Additional load of channel by subdomain ahead of CanCan if a
  # channel_id is not present.
  def load_channel_by_subdomain
    @channel = Channel.find_by_subdomain(request.subdomains[0]) unless params[:channel_id]
  end
end
