module V1
  class ReportsController < ApplicationController
    api :GET, '/reports/infected_survivors', 'Percentage of infected survivors.'
    def infected_survivors
      render json: { percentage: Survivor.percentage_infected }
    end

    api :GET, '/reports/non_infected_survivors', 'Percentage of non-infected survivors.'
    def non_infected_survivors
      render json: { percentage: Survivor.percentage_non_infected }
    end

    api :GET, '/reports/resource_average_by_survivor', 'List of resources and their average amount by survivor'
    def resource_average_by_survivor
      render json: SurvivorItem.resources_average_by_survivor, root: 'resources', each_serializer: ResourceAverageSerializer
    end

    api :GET, '/reports/points_lost_by_infection', 'Points lost because of infected survivor.'
    def points_lost_by_infection
      render json: { points_lost: SurvivorItem.points_lost_by_infection }
    end
  end
end
