module V1
  class SurvivorsController < ApplicationController
    before_action :set_survivor, only: [:show, :update_location, :report_infected, :trade]

    def create
      survivor = Survivor.new(new_survivor_params)

      if survivor.save
        render json: survivor, serializer: ResumedSurvivorSerializer, status: :created
      else
        render json: { errors: survivor.errors }, status: :unprocessable_entity
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

    def report_infected
      infected = Survivor.find_by_id params.permit(:survivor_id)['survivor_id']

      unless infected
        return render json: { errors: [I18n.t('message.error.survivor.not_found')] }, status: :bad_request
      end

      flag = infected.infected_flags.build(reporter: @survivor)
      if flag.valid?
        infected.infected_flags << flag
        render status: :ok
      else
        render json: { errors: flag.errors }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotUnique
      return render json: { errors: [I18n.t('message.error.survivor.has_been_reported_by_you')] }, status: :bad_request
    end

    def trade
      trade = TradeForm.new(trade_params.merge(origin_survivor_id: @survivor.id))

      if trade.perform
        render status: :ok
      else
        render json: { errors: trade.errors }, status: :bad_request
      end
    end

    private

    def set_survivor
      @survivor = Survivor.only_alive.find(params[:id])
    end

    def trade_params
      params.permit(:target_survivor_id).tap do |whitelisted|
        whitelisted[:items] = params[:items].permit! if params.key? :items
      end
    end

    def survivor_location_params
      params.permit(:last_location)
    end

    def new_survivor_params
      params.fetch(:survivor, {}).permit(:name, :age, :gender, :last_location, items: [:name, :quantity])
    end
  end
end