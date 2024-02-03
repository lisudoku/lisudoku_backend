class Api::PuzzleCollectionsController < ApplicationController
  before_action :authenticate_user!, only: %i[index create destroy update]
  load_resource only: %i[show destroy update add_puzzle remove_puzzle]

  def index
    authorize! :read_all, PuzzleCollection

    serialized_puzzle_collections = PuzzleCollection.order(id: :desc).map do |puzzle_collection|
      PuzzleCollectionSerializer.new(puzzle_collection).as_json
    end

    render json: {
      puzzle_collections: serialized_puzzle_collections,
    }
  end

  def create
    authorize! :create, PuzzleCollection

    puzzle_collection = PuzzleCollection.new(puzzle_collection_params)
    if puzzle_collection.save
      render json: PuzzleCollectionSerializer.new(puzzle_collection).as_json
    else
      render json: {
        errors: puzzle_collection.errors.messages,
      }, status: :bad_request
    end
  end

  def show
    authorize! :read, @puzzle_collection

    render json: PuzzleCollectionSerializer.new(@puzzle_collection).as_json
  end

  def update
    authorize! :manage, @puzzle_collection

    @puzzle_collection.update!(puzzle_collection_update_params)

    render json: PuzzleCollectionSerializer.new(@puzzle_collection).as_json
  end

  def destroy
    authorize! :manage, @puzzle_collection

    @puzzle_collection.destroy!

    render json: PuzzleCollectionSerializer.new(@puzzle_collection).as_json
  end

  def add_puzzle
    authorize! :manage, @puzzle_collection

    puzzle_id = params.require(:puzzle_id)
    puzzle = Puzzle.find(puzzle_id)

    @puzzle_collection.add_puzzle(puzzle)
  end

  def remove_puzzle
    authorize! :manage, @puzzle_collection

    puzzle_id = params.require(:puzzle_id)
    puzzle = Puzzle.find(puzzle_id)

    if @puzzle_collection.remove_puzzle(puzzle)
      render status: :no_content
    else
      render status: :bad_request
    end
  end

  private

  def puzzle_collection_params
    params.require(:puzzle_collection).permit(:name, :url)
  end

  def puzzle_collection_update_params
    params.require(:puzzle_collection).permit(:name, :url)
  end
end
