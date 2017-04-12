FactoryGirl.define do
  factory :water_for_new_survivor, class: SurvivorItem do
    association :survivor, factory: :new_survivor
    association :resource, factory: :water
    quantity 5
  end
end