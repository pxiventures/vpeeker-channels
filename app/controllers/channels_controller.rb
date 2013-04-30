class ChannelsController < ApplicationController 
  before_filter :authenticate_user!, only: [:index]
  before_filter :load_or_redirect_to_subdomain, only: [:show, :embed]
  before_filter :setup_gon, only: [:show, :embed]
  load_and_authorize_resource :channel, except: :embed

  layout "admin", except: [:show, :embed]

  def index
    @channels = Channel.accessible_by(current_ability, :edit).order("name ASC")
  end

  def new
    @channel = Channel.new
    @channel.running = true
  end

  def create
    @channel = current_user.channels.build(params[:channel])
    # If we did this as a before_filter in the model, we'd never be able to
    # set it to nil for unlimited channels.
    @channel.video_limit ||= AppConfig.default_video_limit
    @channel.last_visited_at = Time.now
    
    if @channel.save
      redirect_to channels_path, notice: "Channel saved"
    else
      flash.now[:alert] = @channel.errors.full_messages.to_sentence
      render "new"
    end
  end

  def edit
  end

  def update
    params[:channel][:use_password] = (params[:channel][:use_password] == "1" ? true : false)
    if @channel.update_attributes(params[:channel])
      # mark the channel as recently visited, to make sure we start searching it
      @channel.visited!
      redirect_to channels_path, notice: "Channel updated successfully"
    else
      render "edit"
    end
  end

  def destroy
    if @channel.destroy
      redirect_to channels_path, notice: "Channel deleted"
    else
      redirect_to channels_path, alert: "There was a problem: #{@channel.errors.full_messages.to_sentence}"
    end
  end

  def moderate
    @channel = Channel.find(params[:id])
    @videos = @channel.videos.where(moderated: false).order("created_at DESC").limit(10)
  end

  def show
    raise ActiveRecord::RecordNotFound unless @channel
    @channel.visited!
    render "channels/templates/simple"
  end

  def embed
    render :status => 400, :text => "Sorry, the user that owns this channel does not have the ability to create embeddable channel" and return if @channel.user && @channel.user.cannot?(:embed, @channel)
  end

  private
  
  def load_or_redirect_to_subdomain
    @channel = Channel.find_by_id(params[:id]) if params[:id]
    # Force use of subdomain URL
    redirect_to subdomain_channel_url(subdomain: @channel.subdomain) and return if @channel
    @channel = Channel.find_by_subdomain(request.subdomains[0])
    raise ActiveRecord::RecordNotFound unless @channel
  end

  def setup_gon
    gon.videos_path = subdomain_channel_videos_url(subdomain: @channel.subdomain)
    gon.root_url = root_url
  end

end
