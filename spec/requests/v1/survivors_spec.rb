require 'rails_helper'

RSpec.describe 'V1::Survivors', type: :request do
  before(:each) { load_all_resources }

  describe 'POST /v1/survivors' do
    let(:valid_attributes) { attributes_for(:full_new_survivor) }
    let(:invalid_attributes) { attributes_for(:full_new_survivor).merge(name: nil) }
    context 'with valid params' do
      before { post v1_survivors_path, params: { survivor: valid_attributes } }

      it 'should get http status as created' do
        expect(response).to have_http_status(:created)
      end

      it 'should return survivor info and links' do
        expect(json_response_body).to have_key('survivor')
        expect(json_response_body['survivor']).to have_key('links')
      end

      it 'should add a new survivor with inventory to the database' do
        survivor = Survivor.find_by_id(json_response_body['survivor']['id'])
        expect(survivor).to_not be_nil
        expect(survivor.alive?).to be_truthy

        Resource.all.each do |resource|
          expect(survivor.survivor_items.any? { |item| item.resource_id == resource.id }).to be_truthy
        end
      end
    end
  end

  describe 'GET /v1/survivors/:id' do
    let(:survivor) { create(:full_new_survivor) }

    it 'should view survivor info' do
      get v1_survivor_path(survivor)
      expect(json_response_body).to have_key('survivor')
      expect(json_response_body['survivor']).to have_key('inventory')
    end
  end

  describe 'GET /v1/survivors/:id/update_location' do
    let(:survivor) { create(:full_new_survivor) }
    let(:params) { { last_location: '-23.681531,-46.875489' } }

    before do
      put update_location_v1_survivor_path(survivor), params: params
      survivor.reload
    end

    it 'should update new position' do
      expect(response).to have_http_status(:ok)
      expect(survivor.last_location).to eq(params[:last_location])
    end
  end

  describe 'GET /v1/survivors/:id/report_infected' do
    let(:reporter) { create(:full_new_survivor) }
    let(:infected) { create(:full_new_survivor) }
    let(:params) { { survivor_id: infected.id } }

    before do
      put report_infected_v1_survivor_path(reporter), params: params
      infected.reload
    end

    it 'should update new position' do
      expect(response).to have_http_status(:ok)
      expect(infected.flags_count).to eq(1)
    end
  end

  describe 'GET /v1/survivors/:id/trade' do
    let(:origin) { create(:full_new_survivor) }
    let(:target) { create(:full_new_survivor) }
    let(:params) do
      {
        target_survivor_id: target.id,
        items: {
          sending: { 'Water' => 1, 'Food' => 1 },
          requesting: { 'Ammunition' => 3, 'Medication' => 2 }
        }
      }
    end

    before do
      origin.survivor_items.each { |item| item.update(quantity: 15) }
      target.survivor_items.each { |item| item.update(quantity: 10) }

      put trade_v1_survivor_path(origin), params: params

      origin.reload
      target.reload
    end

    it 'should trade items successfully' do
      expect(response).to have_http_status(:ok)

      check_transference_from_to(origin, target, 15, 10, params[:items][:sending])
      check_transference_from_to(target, origin, 10, 15, params[:items][:requesting])
    end

    def check_transference_from_to(from, to, old_value_from, old_value_to, items)
      items.each do |resource_name, amount|
        from_item = from.survivor_items.find { |survivor_item| survivor_item.resource.name == resource_name }
        to_item = to.survivor_items.find { |survivor_item| survivor_item.resource.name == resource_name }
        expect(from_item.quantity).to eq(old_value_from - amount)
        expect(to_item.quantity).to eq(old_value_to + amount)
      end
    end
  end
end
