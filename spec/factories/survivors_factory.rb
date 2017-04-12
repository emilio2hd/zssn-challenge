FactoryGirl.define do
  factory :new_survivor, class: Survivor do
    name { FFaker::Name.first_name }
    age 25
    gender 'female'
    last_location '-16.642442,-49.402550'
    status 'alive'
  end

  factory :full_new_survivor, class: Survivor do
    name { FFaker::Name.first_name }
    age 30
    gender 'male'
    last_location '-16.642442,-49.402550'
    status 'alive'
    items do
      [ { name: 'Water', quantity: '5' }, { name: 'Food', quantity: '10' }, { name: 'Medication', quantity: '15' } ]
    end
  end
end