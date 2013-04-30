# Public: Checks for channels that need searches performing against them based
# on their last search date & their interval.
#
# Could be used as a repeatedly-run process (e.g. by Resque) or a long running
# process (just whack it in a while loop)
class Searcher

  # WARNING: Do not perform this across more than one thread; you'll probably
  # get things running searches more than once.
  def self.perform
    channels = Channel.where("running AND (searched_at IS NULL OR interval IS NULL OR searched_at + interval * '1 second'::interval < ?)", Time.now)
    channels.each do |channel|
      if channel.recently_visited? || !channel.searched_at || channel.searched_at < AppConfig.channels.activity_threshold.ago
        channel.perform_search
      end
    end
  end

end

