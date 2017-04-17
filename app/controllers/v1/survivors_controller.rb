module V1
  class SurvivorsController < ApplicationController
    before_action :set_full_survivor, only: [:show]
    before_action :set_survivor, only: [:update_location, :report_infected, :trade]

    api :POST, '/survivors', 'Add a new survivor to the database'
    error :code => 400, :desc => 'The survivor data has validation errors'
    api_version 'v1'
    param :survivor, Hash, desc: 'Survivor info' do
      param :name, String, desc: 'Survivor\'s name', required: true
      param :age, Integer, desc: 'Survivor\'s title', required: true
      param :gender, [:female, :male, :other], desc: 'Survivor\'s gender', required: true
      param :last_location, String, desc: 'Survivor\'s last location', required: true
      param :items, Hash, desc: 'Survivor\'s inventory of resources' do
        param :name, String, desc: 'Resource\'s name', required: true
        param :quantity, Integer, desc: 'Resource\'s quantity'
      end
    end
    def create
      survivor = Survivor.new(new_survivor_params)

      if survivor.save
        render json: survivor, serializer: ResumedSurvivorSerializer, status: :created
      else
        render json: { errors: survivor.errors }, status: :bad_request
      end
    end

    api :GET, '/survivors/:id', 'Get survivor info and its inventory'
    error :code => 404, :desc => 'The survivor was not found'
    api_version 'v1'
    param :id, Integer, desc: 'Survivor\'s id', required: true
    def show
      render json: @survivor
    end

    api :PUT, '/survivors/:id/update_location', 'Update survivor location'
    error :code => 404, :desc => 'The survivor was not found'
    error :code => 400, :desc => 'The last location has validation errors'
    api_version 'v1'
    param :id, Integer, desc: 'Survivor\'s id', required: true
    param :last_location, String, desc: 'Survivor\'s last location', required: true
    def update_location
      if @survivor.update(survivor_location_params)
        render status: :ok
      else
        render json: { errors: @survivor.errors }, status: :bad_request
      end
    end

    api :PUT, '/survivors/:id/report_infected', 'Flag a survivor as infected'
    error :code => 404, :desc => 'The survivor was not found'
    error :code => 400, :desc => 'There are some validations errors'
    api_version 'v1'
    param :id, Integer, desc: 'Survivor\'s id', required: true
    param :survivor_id, String, desc: 'Survivor\'s id, who is infected', required: true
    def report_infected
      infected = Survivor.find_by_id params.permit(:survivor_id)['survivor_id']

      unless infected
        return render json: { errors: { survivor_id: I18n.t('message.error.survivor.not_found') } }, status: :bad_request
      end

      flag = infected.infected_flags.build(reporter: @survivor)
      if flag.valid?
        infected.infected_flags << flag
        render status: :ok
      else
        render json: { errors: flag.errors }, status: :bad_request
      end
    rescue ActiveRecord::RecordNotUnique
      return render json: { errors: { survivor_id: I18n.t('message.error.survivor.has_been_reported_by_you') } }, status: :bad_request
    end

    api :PUT, '/survivors/:id/trade', 'Trade items with another survivor'
    error :code => 404, :desc => 'The survivor was not found'
    error :code => 400, :desc => 'There are some validations errors'
    api_version 'v1'
    param :id, Integer, desc: 'Survivor\'s id', required: true
    param :target_survivor_id, String, desc: 'Survivor\'s id, who will be the target of the trade', required: true
    param :items, Hash, desc: 'Items to be traded', required: true do
      param :sending, Hash, desc: 'Items that will be sent', required: true
      param :requesting, Integer, desc: 'Items that will be requested', required: true
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

    def set_full_survivor
      @survivor = Survivor.only_alive.includes(survivor_items: :resource).find(params[:id])
    end

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