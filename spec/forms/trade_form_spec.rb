require 'rails_helper'

RSpec.describe TradeForm, type: :model do
  before(:each) { load_all_resources }

  let(:origin) { create(:full_new_survivor) }
  let(:target) { create(:full_new_survivor) }
  let(:trade_params) { {} }

  it { is_expected.to validate_presence_of(:target_survivor_id) }
  it { is_expected.to validate_presence_of(:origin_survivor_id) }
  it { is_expected.to validate_presence_of(:items) }

  subject { TradeForm.new(trade_params) }

  describe 'validations' do
    context 'when a trade is made with infected survivor' do
      let(:target) { create(:infected_survivor) }
      let(:trade_params) { { origin_survivor_id: origin.id, target_survivor_id: target.id } }

      it 'should be invalid' do
        expect(subject.valid?).to be_falsey
        expect(subject.errors.key?(:target_survivor_id)).to be_truthy
      end
    end

    context 'when survivor trade with itself' do
      let(:target) { create(:infected_survivor) }
      let(:trade_params) { { origin_survivor_id: origin.id, target_survivor_id: origin.id } }

      it 'should be invalid' do
        expect(subject.valid?).to be_falsey
        expect(subject.errors.details[:target_survivor_id]).to eq([{ error: :trade_with_yourself }])
      end
    end

    context 'when amount of points is not equal' do
      let(:trade_params) do
        { origin_survivor_id: origin.id, target_survivor_id: target.id,
          items: { sending: { 'Water' => 1, 'Medication' => 1 }, requesting: { 'Ammunition' => 5 } } }
      end

      it 'should be invalid' do
        expect(subject.valid?).to be_falsey
        expect(subject.errors.key?(:items)).to be_truthy
        expect(subject.errors.details[:items]).to eq([{ error: :different_amount_points }])
      end
    end

    context 'when origin trade does not have enough balance' do
      let(:origin) { create(:full_new_survivor, items: [{ name: 'Water', quantity: '2' }]) }
      let(:trade_params) do
        { origin_survivor_id: origin.id, target_survivor_id: target.id,
          items: { sending: { 'Water' => 3 }, requesting: { 'Food' => 4 } } }
      end

      it 'should be invalid' do
        expect(subject.valid?).to be_falsey
        expect(subject.errors.key?(:items)).to be_truthy
        expect(subject.errors.details[:items]).to eq([{ error: :origin_does_not_have_enough_balance, resource_name: 'Water' }])
      end
    end

    context 'when the "item" property exists, but there is no "sending" neither "requesting"' do
      let(:trade_params) { { origin_survivor_id: origin.id, target_survivor_id: target.id, items: {} } }

      it 'should be invalid' do
        expect(subject.valid?).to be_falsey
        expect(subject.errors.key?(:items)).to be_truthy
        expect(subject.errors.details[:items]).to eq([{ error: :blank }])
      end
    end

    context 'when the "item" property exists, but it is not a map' do
      let(:trade_params) { { origin_survivor_id: origin.id, target_survivor_id: target.id, items: 'Water' } }

      it 'should be invalid' do
        expect(subject.valid?).to be_falsey
        expect(subject.errors.key?(:items)).to be_truthy
        expect(subject.errors.details[:items]).to eq([{ error: :not_a_map }])
      end
    end

    context 'when the item property has sending and requesting empty' do
      let(:trade_params) do
        { origin_survivor_id: origin.id, target_survivor_id: target.id,
          items: { sending: {}, requesting: {} } }
      end

      it 'should be invalid' do
        expect(subject.valid?).to be_falsey
        expect(subject.errors.key?(:items)).to be_truthy
        expect(subject.errors.details[:items]).to eq([{ error: :sending_requesting_empty }])
      end
    end

    context 'when everything is correct' do
      let(:trade_params) do
        { origin_survivor_id: origin.id, target_survivor_id: target.id,
          items: { sending: { 'Water' => 1 }, requesting: { 'Ammunition' => 4 } } }
      end

      it 'should be valid' do
        expect(subject.valid?).to be_truthy
      end
    end
  end
end