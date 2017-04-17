class TradeService
  class << self
    def perform(trade_form)
      raise 'A trade_form cant be nil' if trade_form.nil?

      SurvivorItem.transaction do
        move_resources_from_to(trade_form.sending_trade_items, trade_form.origin_survivor_id, trade_form.target_survivor_id)
        move_resources_from_to(trade_form.requesting_trade_items, trade_form.target_survivor_id, trade_form.origin_survivor_id)
      end
    end

    private

    def move_resources_from_to(trade_items, from_survivor_id, to_survivor_id)
      trade_items.each do |trade_item|
        move_resource_from_to(from_survivor_id, to_survivor_id, trade_item)
      end
    end

    def move_resource_from_to(from_survivor_id, to_survivor_id, trade_item)
      quoted_column = SurvivorItem.connection.quote_column_name('quantity')

      SurvivorItem.where(resource_id: trade_item.resource_id, survivor_id: from_survivor_id)
                  .update_all "#{quoted_column} = COALESCE(#{quoted_column}, 0) - #{trade_item.amount}"
      SurvivorItem.where(resource_id: trade_item.resource_id, survivor_id: to_survivor_id)
                  .update_all "#{quoted_column} = COALESCE(#{quoted_column}, 0) + #{trade_item.amount}"
    end
  end
end