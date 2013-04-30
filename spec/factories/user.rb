FactoryGirl.define do
  factory :user do
    sequence(:email){|n| "test#{n}@example.com"}
    sequence(:uid){|n| "#{n}"}
    sequence(:nickname){|n| "twitter_name_#{n}"}
    provider "twitter"
    plan
  end
end
