module ChannelsHelper

  def status_text_for(channel)
    if !channel.running
      color = "red"
      text = "This channel is stopped, you can start it again by going to 'manage' next to this channel."
    elsif !channel.recently_visited?
      color = "peru"
      text = "This channel has not been accessed by anyone recently, so we are not fetching new Vines very often. Visit or edit the channel to resume fetching new Vines at normal frequency."
    elsif channel.videos.count == 0
      color = "red"
      text = "This channel has no videos. Maybe it's a new channel? If not, you should check that your search is correct and working properly."
    elsif channel.interval == AppConfig.channels.longest_interval
      color = "green"
      text = "OK! This channel is running but there aren't many new videos regularly being added. This doesn't necessarily indicate an issue. It might mean that not many people are posting Vines that are picked up by your search, but it also might indicate that there is a problem with your search."

      if channel.videos.count < channel.video_limit
        text += "<br /><br />Please note: there are only #{channel.videos.count} videos in this channel, you may see repeated videos when you view this channel."
      end
    else
      color = "green"
      text = "OK! This channel is running and new Vines are being added."
    end
    content_tag :div, class: "channel-status", style:"color:#{color};" do
      text.html_safe
    end
  end

end
