module V1
  class ReportsController < ApplicationController
    def infected_survivors
      render json: { percentage: Survivor.percentage_infected }
    end

    def non_infected_survivors
      render json: { percentage: Survivor.percentage_non_infected }
    end

    def resource_average_by_survivor
      render json: SurvivorItem.resources_average_by_survivor, root: 'resources', each_serializer: ResourceAverageSerializer
    end

    def points_lost_by_infection
      render json: { points_lost: SurvivorItem.points_lost_by_infection }
    end
  end
end
