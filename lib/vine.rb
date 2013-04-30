# TODO: Consider putting all this in the video model?
#
module Vine

  # Public: Construct a thumbnail URL from a video URL
  # returns an empty string if it doesn't work for some reason
  def self.make_thumbnail_url(video_url)
    base = video_url.match(/\/videos\/(.+)$/)[1]
    return "" unless base
    "https://vines.s3.amazonaws.com/thumbs/#{base}.jpg"
  end

  # Public: Returns an expanded Vine URL if the tweet contains one, or nil if
  # there isn't one.
  #
  # tweet - tweet object from the Twitter gem.
  def self.extract_url_from_tweet(tweet)
    vine_url = tweet.urls.select{|u| u.expanded_url.include? "vine.co" }.first
    return vine_url.expanded_url if vine_url
  end

  # Public: Get an MP4 video URL for a Vine based on the Vine URL. Scrapes
  # the page and parses the HTML.
  #
  # Returns a string, which is the video URL. Nil if one wasn't found (which
  # shouldn't really happen).
  def self.get_video_url(url)
    html = Nokogiri::HTML.parse(Typhoeus::Request.get(url, headers: {"User-Agent" => "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)"}).body)
    video = html.at_css("meta[property='twitter:player:stream']")
    return video["content"].split("?")[0] if video
    return nil
  end

end
