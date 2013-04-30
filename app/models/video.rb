class Video < ActiveRecord::Base
  include Extensions::Adminable
  belongs_to :channel
  attr_accessible :approved, :moderated

  # One (rather large) disadvantage of this is it seems to result in
  # Rails attempting to 'save' the serialized data back to the DB every time,
  # even if it hasn't changed. Might be worth using YAML after all?
  #
  # (We also lose object types like datetime. Beware)
  serialize :tweet, IndifferentJson

  validates :video_url, presence: true
  # We'll use vine URLs as unique checks, but a video might be in more than
  # one channel.
  validates :vine_url, presence: true, uniqueness: {scope: :channel_id}
  validates :thumbnail_url, presence: true

  def self.create_from_tweet!(tweet, channel)
    video = Video.create do |video|
      video.tweet = tweet
      video.vine_url = Vine.extract_url_from_tweet(tweet)
      video.video_url = Vine.get_video_url video.vine_url
      video.thumbnail_url = Vine.make_thumbnail_url video.video_url if video.video_url
      video.channel = channel
      video.created_at = tweet.created_at
      video.approved = channel.default_approved_state
    end
    return video
  end

  def caption
    tweet.text
  end
end
