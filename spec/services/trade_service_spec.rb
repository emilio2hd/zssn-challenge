require 'rails_helper'

RSpec.describe TradeService, type: :model do
  before(:each) { load_all_resources }

  collect_resource = ->(item) { { resource_id: item.resource_id, quantity: item.quantity } }

  let(:origin) { create(:full_new_survivor) }
  let!(:origin_old_items) { origin.survivor_items.collect(&collect_resource) }
  let(:target) { create(:full_new_survivor) }
  let!(:target_old_items) { target.survivor_items.collect(&collect_resource) }
  let(:trade_params) do
    { origin_survivor_id: origin.id, target_survivor_id: target.id,
      items: { sending: { 'Water' => 1 }, requesting: { 'Ammunition' => 4 } } }
  end
  let(:trade_form) { TradeForm.new(trade_params) }

  describe '.perform' do
    before { trade_form.validate }

    it 'should move resources from one survivor to another' do
      TradeService.perform(trade_form)

      origin.reload
      target.reload

      resources = Resource.where(name: %w(Water Medication Ammunition))

      get_trade_items = lambda do |resource_name, resource_amount|
        resource = resources.find { |item| item.name == resource_name }
        { resource_id: resource.id, amout: resource_amount }
      end

      sending_items = trade_params[:items][:sending].collect(&get_trade_items)
      requesting_items = trade_params[:items][:requesting].collect(&get_trade_items)

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