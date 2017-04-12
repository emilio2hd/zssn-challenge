class Survivor < ApplicationRecord
  enum status: [ :alive, :infected ]
  enum gender: [ :female, :male, :other ]

  attr_accessor :last_location, :items
  has_many :survivor_items

  validates :name, :age, :gender, :last_location, presence: true
  validates :name, length: { maximum: 255 }

  before_save :split_last_location
  before_validation :build_survivor_items, on: :create

  def combined_last_location
    "#{last_location_lati},#{last_location_long}"
  end

  private

  def split_last_location
    latitude, longitude = last_location.split(',')
    self.last_location_lati = latitude.to_d
    self.last_location_long = longitude.to_d
  end

  def build_survivor_items
    resources = Resource.all

    @survivor_items = resources.collect do |resource|
      found = items.try(:find) { |item| item[:name] == resource.name } || {}
      quantity = found[:quantity] || 0
      survivor_items.build(survivor: self, resource: resource, quantity: quantity)
    end
  end
end
