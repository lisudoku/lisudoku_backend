class Api::PuzzlesController < ApplicationController
  before_action :load_puzzle, only: %i[show check]

  def random
    puzzle = Puzzle.where(puzzle_filters).offset(rand(Puzzle.count)).first

    render json: PuzzleSerializer.new(puzzle).as_json
  end

  def show
    render json: PuzzleSerializer.new(@puzzle).as_json
  end

  def check
    params.require(:grid)
    render json: {
      result: {
        correct: @puzzle.solution == params[:grid]
      }
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
