require 'rails_helper'

RSpec.describe V1::SurvivorsController, type: :controller do
  let(:valid_attributes) { attributes_for(:full_new_survivor) }
  let(:invalid_attributes) { attributes_for(:full_new_survivor).merge(name: nil) }

  before(:all) { load_all_resources }

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new survivor' do
        expect do
          post :create, params: { survivor: valid_attributes }
        end.to change(Survivor, :count).by(1).and change(SurvivorItem, :count).by(4)
      end

      it 'should get http status as created' do
        post :create, params: { survivor: valid_attributes }
        expect(response).to have_http_status(:created)
      end

      it 'return survivor info and inventory link' do
        post :create, params: { survivor: valid_attributes }
        expect(json_response_body).to have_key('survivor')
        expect(json_response_body['survivor']['links']).to have_key('self')
      end
    end

    context 'with invalid params' do
      it 'should contains validation errors in response body' do
        post :create, params: { survivor: invalid_attributes }
        expect(json_response_body).to have_key('errors')
      end

      it 'should get http status as unprocessable_entity' do
        post :create, params: { survivor: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'should not save any item' do
        expect { post :create, params: { survivor: invalid_attributes } }.to change(SurvivorItem, :count).by(0)
      end
    end
  end

  describe 'GET #show' do
    context 'with invalid id' do
      it 'should get http status as not_found' do
        get :show, params: { id: 50 }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with valid id' do
      let(:survivor) { create(:full_new_survivor) }

      before { get :show, params: { id: survivor.id } }

      it 'should get http status as ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'should get survivor with inventory' do
        expect(json_response_body).to have_key('survivor')
        expect(json_response_body['survivor']).to have_key('inventory')
      end
    end
  end

  describe 'PUT #update_location' do
    let(:survivor) { create(:full_new_survivor) }
    let(:update_params) { { id: survivor.id, last_location: '-23.681531,-46.875489' } }

    before { put :update_location, params: update_params }

    context 'with valid last_location' do
      it 'should get http status as ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'should update survivors last_location' do
        survivor.reload
        expect(survivor.combined_last_location).to eq(update_params[:last_location])
      end
    end

    context 'with empty last_location' do
      let(:update_params) { { id: survivor.id } }

      it 'should get http status as unprocessable_entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'should contains validation errors in response body' do
        expect(json_response_body).to have_key('errors')
      end
    end
  end
end
