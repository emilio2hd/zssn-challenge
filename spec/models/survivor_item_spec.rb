require 'rails_helper'

RSpec.describe SurvivorItem, type: :model do
  subject { build(:water_for_new_survivor) }

  it { is_expected.to validate_presence_of(:survivor) }
  it { is_expected.to validate_presence_of(:resource) }
  it { is_expected.to validate_numericality_of(:quantity).only_integer.is_greater_than_or_equal_to(0) }
  it { is_expected.to belong_to(:survivor) }
  it { is_expected.to belong_to(:resource) }
  it { is_expected.to have_db_index([:survivor_id, :resource_id]).unique }

  describe '.percentage_non_infected' do
    before do
      water = create(:water)
      food = create(:food)
      medication = create(:medication)
      ammunition = create(:ammunition)

      items = [
        { name: water.name, quantity: '5' },
        { name: food.name, quantity: '5' },
        { name: medication.name, quantity: '5' },
        { name: ammunition.name, quantity: '5' }
      ]

      create(:new_survivor, items: items)
      create(:new_infected_survivor, items: items)
    end

    it 'should return 50 points' do
      expect(SurvivorItem.points_lost_by_infection).to eq(50)
    end
  end

  describe '.resources_average_by_survivor' do
    before do
      @water = create(:water)
      @food = create(:food)
      @medication = create(:medication)
      @ammunition = create(:ammunition)

      items = [{ name: @water.name, quantity: '2' }, { name: @food.name, quantity: '2' },
               { name: @medication.name, quantity: '4' }, { name: @ammunition.name, quantity: '1' }]
      create(:new_survivor, items: items)

      items = [{ name: @water.name, quantity: '2' }, { name: @food.name, quantity: '4' },
               { name: @medication.name, quantity: '2' }, { name: @ammunition.name, quantity: '1' }]
      create(:new_survivor, items: items)

      items = [{ name: @water.name, quantity: '5' }, { name: @food.name, quantity: '9' },
               { name: @medication.name, quantity: '6' }, { name: @ammunition.name, quantity: '1' }]
      create(:new_survivor, items: items)
    end

    it 'should return a list of resources with their average amount ' do
      items = SurvivorItem.resources_average_by_survivor.to_a
      expected_average = { @water.name => 3, @food.name => 5, @medication.name => 4, @ammunition.name => 1 }

      expected_average.each do |resource_name, average|
        resource = items.find { |item| item.name == resource_name }
        expect(resource.quantity_average).to eq(average)
      end
    end
  end
end