namespace :vpeeker do

  desc "Refresh the subscription data via the Fastspring API"
  task :refresh_subscription_metadata => :environment do

    Subscription.find_each do |subscription|
      begin
        Rails.logger.info "[%s] Updating @%s subscription (%s)" % [Time.now, (subscription.user ? subscription.user.nickname : "UNKNOWN"), subscription.reference]
        fastspring_data = subscription.get_subscription
      rescue FsprgException => e
        Rails.logger.warn "[%s]   Returned an error from Fastspring: %s" % [Time.now, e.message]
      else
        %w(end_date next_period_date status status_reason).each do |key|
          subscription.send("#{key}=", fastspring_data.send(key))
          if subscription.send("#{key}_changed?")
            Rails.logger.info "[%s]    %s = %s" % [Time.now, key, fastspring_data.send(key)]
          end
        end
        subscription.save!
      end
    end

  end

end
