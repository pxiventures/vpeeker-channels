FactoryGirl.define do
  factory :plan do
    name "Super plan"
    embed false
    channels 1
    sequence(:fastspring_reference) {|i| "superplan#{i}"}
    subscribable false

    trait :subscribable do
      subscribable true
    end

    factory :subscribable_plan, traits: [:subscribable]
  end
end
