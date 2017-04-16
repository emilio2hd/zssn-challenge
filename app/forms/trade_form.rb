class TradeForm
  include ActiveModel::Model

  class TradeItem
    attr_accessor :resource_id, :resource_points, :amount
    attr_reader :total_points

    def initialize(resource_id, resource_points, amount)
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

    resource_name_list = (items[:sending].keys + items[:requesting].keys).uniq
    resources = Resource.where(name: resource_name_list)

    create_trade_items = lambda do |resource_name, amount|
      resource = resources.find { |item| item.name == resource_name }
      TradeItem.new(resource.id, resource.points, amount) unless resource.nil?
    end

    @sending_trade_items = items[:sending].collect(&create_trade_items).compact
    @requesting_trade_items = items[:requesting].collect(&create_trade_items).compact

    requesting_points = @sending_trade_items.sum(&:total_points)
    sending_points = @requesting_trade_items.sum(&:total_points)

    errors.add(:items, :different_amount_points) if requesting_points != sending_points
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