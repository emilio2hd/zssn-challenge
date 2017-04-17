require 'rails_helper'

RSpec.describe V1::ReportsController, type: :controller do
  describe 'GET #infected_survivors' do
    let(:expected_percentage) { 68 }

    it 'should return percentage of infected survivors' do
      expect(Survivor).to receive(:percentage_infected).and_return(expected_percentage)

      get :infected_survivors

      expect(json_response_body['percentage']).to eq(expected_percentage)
    end
  end

  describe 'GET #non_infected_survivors' do
    let(:expected_percentage) { 32 }

    it 'should return percentage of non-infected survivors' do
      expect(Survivor).to receive(:percentage_non_infected).and_return(expected_percentage)

      get :non_infected_survivors

      expect(json_response_body['percentage']).to eq(expected_percentage)
    end
  end

  describe 'GET #points_lost_by_infection' do
    let(:expected_points) { 130 }

    it 'should return points lost because of infected survivor' do
      expect(SurvivorItem).to receive(:points_lost_by_infection).and_return(expected_points)

      get :points_lost_by_infection

      expect(json_response_body['points_lost']).to eq(expected_points)
    end
  end

  describe 'GET #resource_average_by_survivor' do
    let(:expected_resources) { { 'Water' => 10, 'Food' => 32, 'Medication' => 20, 'Ammunition' => 15 } }

    before do
      resource_list = expected_resources.collect do |resource_name, average|
        item = double(Resource)
        allow(item).to receive(:read_attribute_for_serialization).with(:name).and_return(resource_name)
        allow(item).to receive(:read_attribute_for_serialization).with(:quantity_average).and_return(average)
        item
      end

      expect(SurvivorItem).to receive(:resources_average_by_survivor).and_return(resource_list)

      get :resource_average_by_survivor
    end

    it 'should return a list of each kind of resource and their average amount by survivor' do
      expected_resources.each do |resource_name, average|
        resource = json_response_body['resources'].find { |item| item['resource'] == resource_name }
        expect(resource).to_not be_nil
        expect(resource['quantity_average']).to eq(average)
      end
    end
  end
end
