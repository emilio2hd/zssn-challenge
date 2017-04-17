FactoryGirl.define do
  factory :new_survivor, class: Survivor do
    name { FFaker::Name.first_name }
    age 25
    gender 'female'
    last_location '-16.642442,-49.402550'
    status 'alive'

    factory :new_infected_survivor, class: Survivor do
      status 'infected'
    end
  end

  factory :full_new_survivor, class: Survivor do
    name { FFaker::Name.first_name }
    age 30
    gender 'male'
    last_location '-16.642442,-49.402550'
    status 'alive'
    items do
      [ { name: 'Water', quantity: '5' }, { name: 'Food', quantity: '10' },
        { name: 'Medication', quantity: '15' }, { name: 'Ammunition', quantity: '5' } ]
    end

    factory :survivor_flagged_twice, class: Survivor do
      transient { flags_count 2 }

      after(:create) do |survivor, evaluator|
        create_list(:flag, evaluator.flags_count, infected: survivor)
      end
    end

    factory :infected_survivor, class: Survivor do
      status 'infected'
    end
  end
end