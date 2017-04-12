module V1
  class SurvivorsController < ApplicationController
    before_action :set_survivor, only: [:show, :update_location, :update, :destroy]

    def create
      @survivor = Survivor.new(new_survivor_params)

      if @survivor.save
        render json: @survivor, serializer: ResumedSurvivorSerializer, status: :created
      else
        render json: { errors: @survivor.errors }, status: :unprocessable_entity
      end
    end

    def show
      render json: @survivor
    end

    def update_location
      if @survivor.update(survivor_location_params)
        render status: :ok
      else
        render json: { errors: @survivor.errors }, status: :unprocessable_entity
      end
    end

    private

    def set_survivor
      @survivor = Survivor.find(params[:id])
    end

    def survivor_location_params
      params.permit(:last_location)
    end

    def new_survivor_params
      params.fetch(:survivor, {}).permit(:name, :age, :gender, :last_location, items: [:name, :quantity])
    end
  end
end