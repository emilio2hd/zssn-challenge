class Survivor < ApplicationRecord
  enum status: [ :alive, :infected ]
  enum gender: [ :female, :male, :other ]

  attr_accessor :items
  has_many :survivor_items
  has_many :infected_flags, foreign_key: 'infected_id', counter_cache: :flags_count

  validates :name, :age, :gender, :last_location, presence: true
  validates :name, length: { maximum: 255 }

  before_validation :build_survivor_items, on: :create

  scope :only_alive, -> { where(status: :alive) }
  scope :only_infected, -> { where(status: :infected) }

  def last_location=(last_location)
    self.last_location_lati = nil
    self.last_location_long = nil

    unless last_location.to_s.empty?
      latitude, longitude = last_location.to_s.split(',')
      self.last_location_lati = latitude.to_d
      self.last_location_long = longitude.to_d
    end
  end

  def last_location
    return nil if !last_location_lati && !last_location_long
    "#{last_location_lati},#{last_location_long}"
  end

  def check_status
    infected! if flags_count >= 3
  end

  class << self
    def percentage_infected
      percentage_of(only_infected)
    end

    def percentage_non_infected
      percentage_of(only_alive)
    end

    private

    def percentage_of(status)
      (status.count.to_f / count.to_f * 100).round(2)
    end
  end

  private

  def build_survivor_items
    resources = Resource.all_cached

    @survivor_items = resources.collect do |resource|
      found = items.try(:find) { |item| item[:name] == resource.name } || {}
      quantity = found[:quantity] || 0
      survivor_items.build(survivor: self, resource: resource, quantity: quantity)
    end
  end
end
