class TradeForm
  include ActiveModel::Model

  class TradeItem
    attr_accessor :resource_name, :resource_id, :resource_points, :amount
    attr_reader :total_points

    def initialize(resource_name, resource_id, resource_points, amount)
      @resource_name = resource_name
      @resource_id = resource_id
      @resource_points = resource_points
      @amount = amount.to_i
      @total_points = @resource_points * @amount
    end
  end

  attr_accessor :target_survivor_id, :origin_survivor_id, :items

  validates :target_survivor_id, :origin_survivor_id, :items, presence: true
  validate :validate_survivor_alive, :validate_items

  def perform
    return false unless valid?
    move_resources
    true
  end

  private

  def validate_items
    validate_item_format
    validate_amount_of_points
    validate_enough_balance
  end

  def validate_survivor_alive
    errors.add(:target_survivor_id, :not_alive) unless Survivor.only_alive.exists?(target_survivor_id)
  end

  def validate_item_format
    return errors.add(:items, :not_a_map) unless items.is_a? Hash
    return errors.add(:items, :not_a_map_with_sending_requesting_keys) unless items.key?(:sending) || items.key?(:requesting)
    items[:sending] = Hash.try_convert(items[:sending]) || {}
    items[:requesting] = Hash.try_convert(items[:requesting]) || {}
    errors.add(:items, :sending_requesting_empty) if items[:sending].empty? || items[:requesting].empty?
  end

  def validate_amount_of_points
    return if errors.key? :items

    create_trade_items = lambda do |resource_name, amount|
      resource = Resource.find_by_name_cached(resource_name)
      TradeItem.new(resource_name, resource.id, resource.points, amount) unless resource.nil?
    end

    @sending_trade_items = items[:sending].collect(&create_trade_items).compact
    @requesting_trade_items = items[:requesting].collect(&create_trade_items).compact

    requesting_points = @sending_trade_items.sum(&:total_points)
    sending_points = @requesting_trade_items.sum(&:total_points)

    errors.add(:items, :different_amount_points) if requesting_points != sending_points
  end

  def validate_enough_balance
    return if errors.key? :items

    resource_id_list = @sending_trade_items.collect(&:resource_id)
    SurvivorItem.where(resource_id: resource_id_list, survivor_id: origin_survivor_id).each do |current_item|
      trade_item = @sending_trade_items.find { |sending_item| sending_item.resource_id == current_item.resource_id }
      if (current_item.quantity - trade_item.amount) <= 0
        errors.add(:items, :origin_does_not_have_enough_balance, resource_name: trade_item.resource_name)
      end
    end

    resource_id_list = @requesting_trade_items.collect(&:resource_id)
    SurvivorItem.where(resource_id: resource_id_list, survivor_id: target_survivor_id).each do |current_item|
      trade_item = @requesting_trade_items.find { |sending_item| sending_item.resource_id == current_item.resource_id }
      if (current_item.quantity - trade_item.amount) <= 0
        errors.add(:items, :target_does_not_have_enough_balance, resource_name: trade_item.resource_name)
      end
    end
  end

  def move_resources
    SurvivorItem.transaction do
      move_resources_from_to(@sending_trade_items, origin_survivor_id, target_survivor_id)
      move_resources_from_to(@requesting_trade_items, target_survivor_id, origin_survivor_id)
    end
  end

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