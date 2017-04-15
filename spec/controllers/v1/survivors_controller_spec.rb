require 'rails_helper'

RSpec.shared_examples 'check_bad_request' do
  it 'should get http status as bad_request' do
    expect(response).to have_http_status(:bad_request)
  end

  it 'should contains errors in response body' do
    expect(json_response_body).to have_key('errors')
    expect(json_response_body['errors'].count).to eq(1)
  end
end

RSpec.describe V1::SurvivorsController, type: :controller do
  let(:valid_attributes) { attributes_for(:full_new_survivor) }
  let(:invalid_attributes) { attributes_for(:full_new_survivor).merge(name: nil) }

  before(:each) { load_all_resources }

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

    context 'when survivor is infected' do
      let(:survivor) { create(:infected_survivor) }

      before { get :show, params: { id: survivor.id } }

      it 'should get http status as not_found' do
        expect(response).to have_http_status(:not_found)
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
        expect(survivor.last_location).to eq(update_params[:last_location])
      end
    end

    context 'with empty last_location' do
      let(:update_params) { { id: survivor.id, last_location: '' } }

      it 'should get http status as unprocessable_entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'should contains validation errors in response body' do
        expect(json_response_body).to have_key('errors')
      end
    end

    context 'when survivor is infected' do
      let(:survivor) { create(:infected_survivor) }

      it 'should get http status as not_found' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PUT #report_infected' do
    let(:reporter) { create(:full_new_survivor) }
    let(:infected) { create(:full_new_survivor) }
    let(:infected_survivor_id) { infected.id }

    context 'when params are correct' do
      before do
        @old_flags_count = infected.flags_count

        put :report_infected, params: { id: reporter.id, survivor_id: infected_survivor_id }

        infected.reload
        @new_flags_count = infected.flags_count
      end

      it 'should get http status as ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'should increment the flags counter' do
        expect(@new_flags_count).to eq(@old_flags_count + 1)
      end

      it 'should keep status as alive' do
        expect(infected.alive?).to be_truthy
      end

      context 'and survivor already has twos flags' do
        let(:infected) { create(:survivor_flagged_twice) }

        it 'should get http status as ok' do
          expect(response).to have_http_status(:ok)
        end

        it 'should increment the flags counter' do
          expect(@new_flags_count).to eq(@old_flags_count + 1)
        end

        it 'should update infected status to "infected"' do
          expect(infected.infected?).to be_truthy
        end
      end

      context 'and survivor is infected' do
        let(:reporter) { create(:infected_survivor) }

        it 'should get http status as not_found' do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when reporter has already reported a survivor as infected' do
      before do
        create(:flag, infected: infected, reporter: reporter)
        put :report_infected, params: { id: reporter.id, survivor_id: infected_survivor_id }
      end

      include_examples 'check_bad_request'
    end

    context 'when survivor does not exist' do
      let(:infected_survivor_id) { -1 }

      before { put :report_infected, params: { id: reporter.id, survivor_id: infected_survivor_id } }

      include_examples 'check_bad_request'
    end
  end

  describe 'PUT #trade' do
    let(:source) { create(:full_new_survivor) }
    let(:destiny) { create(:full_new_survivor) }

    context 'with valid data' do
      before do
        items = { sending: { 'Water' => 1, 'Medication' => 1 }, requesting: { 'Ammunition' => 6 } }
        put :trade, params: { id: source.id, target_survivor_id: destiny.id, items: items }
      end

      it 'should get http status as ok' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid data' do
      before { put :trade, params: { id: source.id } }

      it 'should get http status as bad_request and has errors' do
        expect(response).to have_http_status(:bad_request)
        expect(json_response_body).to have_key('errors')
      end
    end

    context 'when survivor does not exist' do
      let(:source) { create(:infected_survivor) }

      before { put :trade, params: { id: source.id } }

      it 'should get http status as not_found' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
