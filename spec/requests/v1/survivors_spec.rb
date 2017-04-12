require 'rails_helper'

RSpec.describe 'V1::Survivors', type: :request do
  before(:all) { load_all_resources }

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

    it 'should update survivor last location' do
      get v1_survivor_path(survivor)
      expect(json_response_body).to have_key('survivor')
      expect(json_response_body['survivor']).to have_key('inventory')
    end
  end
end
