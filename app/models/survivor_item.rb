class SurvivorItem < ApplicationRecord
  belongs_to :survivor
  belongs_to :resource

  validates :survivor, :resource, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  class << self
    def points_lost_by_infection
      Rails.cache.fetch('report/points_lost_by_infection', expires_in: 6.hours) do
        joins(:resource, :survivor)
          .where(survivors: { status: 'infected' })
          .sum('(quantity * resources.points)')
      end
    end

    def resources_average_by_survivor
      Rails.cache.fetch('resources_average_by_survivor') { calculate_resource_average }
    end

    private

    def calculate_resource_average
      resources = Resource.arel_table
      survivor_items = SurvivorItem.arel_table
      survivors = Survivor.arel_table

      query = resources.project(resources[:name], Arel.sql('COALESCE(AVG(quantity), 0) as quantity_average'))
                       .join(survivor_items, Arel::Nodes::OuterJoin).on(resources[:id].eq(survivor_items[:resource_id]))
                       .join(survivors, Arel::Nodes::OuterJoin).on(survivor_items[:survivor_id].eq(survivors[:id]), survivors[:status].eq(:alive))
                       .group(resources[:id])

      Resource.find_by_sql(query.to_sql)
    end
  end
end