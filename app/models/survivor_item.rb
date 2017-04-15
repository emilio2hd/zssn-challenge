class SurvivorItem < ApplicationRecord
  belongs_to :survivor
  belongs_to :resource

  validates :survivor, :resource, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  class << self
    def points_lost_by_infection
      joins(:resource, :survivor)
        .where(survivors: { status: 'infected' })
        .sum('(quantity * resources.points)')
    end

    def resources_average_by_survivor
      select('resources.name', 'AVG(quantity) as quantity_average')
        .joins(:resource, :survivor)
        .where(survivors: { status: 'alive' })
        .group('resource_id')
    end
  end
end