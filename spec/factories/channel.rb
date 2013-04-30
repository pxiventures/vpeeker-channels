FactoryGirl.define do
  factory :channel do

    name "My channel"
    sequence(:subdomain){|s| "my-channel-#{s}"}
    running true
    search "#cat"
    video_limit (AppConfig.remember_videos + 1)
    default_approved_state true

    user

  end
end
