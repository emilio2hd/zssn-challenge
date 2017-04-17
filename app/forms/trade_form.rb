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
  attr_reader :sending_trade_items, :requesting_trade_items

  def initialize(attributes={})
    super(attributes)
    after_initialize
  end

  validates :target_survivor_id, :origin_survivor_id, :items, presence: true
  validate :validate_survivor_alive, :validate_items

  def after_initialize
    @sending_trade_items = []
    @requesting_trade_items = []
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
    return if errors.key? :items

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

    validate_balance(@sending_trade_items, origin_survivor_id, :origin_does_not_have_enough_balance)
    validate_balance(@requesting_trade_items, target_survivor_id, :target_does_not_have_enough_balance)
  end

  def validate_balance(trade_items, survivor_id, msg_key)
    resource_id_list = trade_items.collect(&:resource_id)
    SurvivorItem.where(resource_id: resource_id_list, survivor_id: survivor_id).each do |current_item|
      trade_item = trade_items.find { |item| item.resource_id == current_item.resource_id }
      if (current_item.quantity - trade_item.amount).negative?
        errors.add(:items, msg_key, resource_name: trade_item.resource_name)
      end
    end
  end
end