class Api::CompetitionsController < ApplicationController
  before_action :authenticate_user!, only: %i[create destroy update]
  load_resource only: %i[show destroy update]

  def index
    authorize! :read, Competition

    competitions_query = Competition.order(:id)
    cache_key = 'competitions'
    if params[:active] == 'true'
      cache_key += '_active'
      competitions_query = competitions_query.where(
        'tsrange(from_date, to_date) && tsrange(:show_from, :show_to)',
        show_from: 5.days.ago,
        show_to: 5.days.from_now
      )
    end

    competitions = Rails.cache.fetch(cache_key, expires_in: 24.hours) do
      competitions_query.to_a
    end
    serialized_competitions = competitions.map do |competition|
      CompetitionSerializer.new(competition).as_json
    end

    render json: {
      competitions: serialized_competitions,
    }
  end

  def create
    authorize! :create, Competition

    competition = Competition.new(competition_params)
    if competition.save
      Competition.invalidate_cache
      render json: CompetitionSerializer.new(competition).as_json
    else
      render json: {
        errors: competition.errors.messages,
      }, status: :bad_request
    end
  end

  def show
    authorize! :read, @competition

    render json: CompetitionSerializer.new(@competition).as_json
  end

  def update
    authorize! :manage, @competition

    @competition.update!(competition_update_params)

    Competition.invalidate_cache

    render json: CompetitionSerializer.new(@competition).as_json
  end

  def destroy
    authorize! :manage, @competition

    @competition.destroy!

    Competition.invalidate_cache

    render json: CompetitionSerializer.new(@competition).as_json
  end

  private

  def competition_params
    params.require(:competition).permit(
      :name, :url, :from_date, :to_date, :puzzle_collection_id, :ib_puzzle_collection_id
    )
  end

  def competition_update_params
    params.require(:competition).permit(
      :name, :url, :from_date, :to_date, :puzzle_collection_id, :ib_puzzle_collection_id
    )
  end
end
