class Api::PuzzlesController < ApplicationController
  before_action :load_puzzle, only: %i[show check]

  def random
    puzzles_query = Puzzle.where(puzzle_filters)
    random_offset = rand(puzzles_query.count)
    puzzle = puzzles_query.offset(random_offset).first

    if puzzle.blank?
      render json: {}.as_json, status: :not_found
      return
    end

    render json: PuzzleSerializer.new(puzzle).as_json
  end

  def show
    render json: PuzzleSerializer.new(@puzzle).as_json
  end

  def check
    params.require(:grid)
    render json: {
      correct: @puzzle.solution == params[:grid],
    }
  end

  private

  def load_puzzle
    @puzzle = Puzzle.where(public_id: params[:id]).sole
  end

  def puzzle_filters
    params.require([:variant, :difficulty])
    params.permit(:variant, :difficulty)
  end
end
