FactoryGirl.define do
  factory :subscription do
    user
    sequence(:reference){|s| "subscription_#{s}"}
  end
end
