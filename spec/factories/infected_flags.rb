FactoryGirl.define do
  factory :flag, class: InfectedFlag do
    association :infected, factory: :full_new_survivor
    association :reporter, factory: :full_new_survivor
  end
end
