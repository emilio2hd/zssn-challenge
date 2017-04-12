FactoryGirl.define do
  factory :water, class: Resource do
    name 'Water'
    points 4
  end

  factory :food, class: Resource do
    name 'Food'
    points 3
  end

  factory :medication, class: Resource do
    name 'Medication'
    points 2
  end

  factory :ammunition, class: Resource do
    name 'Ammunition'
    points 1
  end
end