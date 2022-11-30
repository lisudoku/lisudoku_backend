class Api::PuzzlesController < ApplicationController
  before_action :load_puzzle, only: %i[show check]

  def random
    puzzles_query = Puzzle.where(puzzle_filters)
    random_offset = rand(puzzles_query.count)
    puzzle = puzzles_query.offset(random_offset).first

    if puzzle.blank?
      render json: {}, status: :not_found
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

  def create
    # TODO: only admins should have permission to this action
    # TODO: check that there isn't a identical/similar puzzle

    puzzle = Puzzle.new(puzzle_params)
    if puzzle.save
      render json: PuzzleSerializer.new(puzzle).as_json
    else
      render json: {
        errors: puzzle.errors.messages,
      }, status: :bad_request
    end
  end

  private

  def load_puzzle
    @puzzle = Puzzle.where(public_id: params[:id]).sole
  end

  def puzzle_filters
    params.require([:variant, :difficulty])
    params.permit(:variant, :difficulty)
  end

  def puzzle_params
    # permit doesn't work with nested arrays :-/
    params.require(:puzzle).permit!
    params.require(:puzzle).to_h.slice(:constraints, :variant, :difficulty, :solution)
  end
end
