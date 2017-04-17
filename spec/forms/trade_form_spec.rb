require 'rails_helper'

RSpec.describe TradeForm, type: :model do
  let(:origin) { create(:full_new_survivor) }
  let(:target) { create(:full_new_survivor) }
  it { is_expected.to validate_presence_of(:target_survivor_id) }
  it { is_expected.to validate_presence_of(:origin_survivor_id) }
  it { is_expected.to validate_presence_of(:items) }

  describe 'validations' do
    context 'when a trade is made with infected survivor' do
      let(:target) { create(:infected_survivor) }

      it 'should be invalid' do
        trade_params = { origin_survivor_id: origin.id, target_survivor_id: target.id }
        trade = TradeForm.new(trade_params)

        expect(trade.valid?).to be_falsey
        expect(trade.errors.key?(:target_survivor_id)).to be_truthy
      end
    end

    context 'when amount of points is no equal' do
      before do
        create(:water)
        create(:medication)
        create(:ammunition)
      end

      it 'should be invalid' do
        trade_params = {
          origin_survivor_id: origin.id,
          target_survivor_id: target.id,
          items: { sending: { 'Water' => 1, 'Medication' => 1 }, requesting: { 'Ammunition' => 5 } }
        }

        trade = TradeForm.new(trade_params)

        expect(trade.valid?).to be_falsey
        expect(trade.errors.key?(:items)).to be_truthy
      end
    end

    context 'when the item property exists, there is not sending nor requesting' do
      it 'should be invalid' do
        trade_params = { origin_survivor_id: origin.id, target_survivor_id: target.id, items: {} }

        trade = TradeForm.new(trade_params)

        expect(trade.valid?).to be_falsey
      end
    end

    context 'when the item property, has sending and requesting empty' do
      it 'should be invalid' do
        trade_params = {
          origin_survivor_id: origin.id,
          target_survivor_id: target.id,
          items: { sending: {}, requesting: {} }
        }

        trade = TradeForm.new(trade_params)

        expect(trade.valid?).to be_falsey
      end
    end

    context 'when everything is correct' do
      before do
        create(:water)
        create(:medication)
        create(:ammunition)
      end

      it 'should be valid' do
        trade_params = {
          origin_survivor_id: origin.id,
          target_survivor_id: target.id,
          items: { sending: { 'Water' => 1 }, requesting: { 'Ammunition' => 4 } }
        }

        trade = TradeForm.new(trade_params)

        expect(trade.valid?).to be_truthy
      end
    end
  end

  describe '#perform' do
    before do
      create(:water)
      create(:medication)
      create(:ammunition)
    end

    it 'should move resources from one survivor to another' do
      trade_params = {
        origin_survivor_id: origin.id,
        target_survivor_id: target.id,
        items: { sending: { 'Water' => 1 }, requesting: { 'Ammunition' => 4 } }
      }

      collect_resource = ->(item) { { resource_id: item.resource_id, quantity: item.quantity } }
      origin_old_items = origin.survivor_items.collect(&collect_resource)
      target_old_items = target.survivor_items.collect(&collect_resource)

      trade = TradeForm.new(trade_params)
      trade.perform

      resources = Resource.where(name: %w(Water Medication Ammunition))

      get_trade_items = lambda do |resource_name, resource_amount|
        resource = resources.find { |item| item.name == resource_name }
        { resource_id: resource.id, amout: resource_amount }
      end

      sending_items = trade_params[:items][:sending].collect(&get_trade_items)
      requesting_items = trade_params[:items][:requesting].collect(&get_trade_items)

      origin.reload
      target.reload

      origin_new_items = origin.survivor_items.collect(&collect_resource)
      target_new_items = target.survivor_items.collect(&collect_resource)

      expect_move_resource(sending_items, origin_new_items, origin_old_items, '-')
      expect_move_resource(requesting_items, origin_new_items, origin_old_items, '+')

      expect_move_resource(sending_items, target_new_items, target_old_items, '+')
      expect_move_resource(requesting_items, target_new_items, target_old_items, '-')
    end

    def expect_move_resource(trade_items, new_items, old_items, op)
      trade_items.each do |trade_item|
        new_item = new_items.find { |item| item[:resource_id] == trade_item[:resource_id] }
        old_item = old_items.find { |item| item[:resource_id] == trade_item[:resource_id] }
        expect(new_item[:quantity]).to eq(old_item[:quantity].public_send(op, trade_item[:amout]))
      end
    end
  end
end