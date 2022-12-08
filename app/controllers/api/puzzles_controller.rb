class Api::PuzzlesController < ApplicationController
  before_action :load_puzzle, only: %i[show check destroy]

  def random
    # TODO: should definitely cache this (depending on puzzle_filters)
    all_puzzle_ids = Puzzle.where(puzzle_filters).select(:public_id).pluck(:public_id)

    puzzle_ids = all_puzzle_ids - params[:id_blacklist]

    puzzle = if puzzle_ids.present?
      random_index = rand(puzzle_ids.size)
      puzzle_id = puzzle_ids[random_index]
      Puzzle.find_by(public_id: puzzle_id)
    end

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

  def index
    # TODO: only admins should have permission to this action
    serialized_puzzles = Puzzle.all.map do |puzzle|
      PuzzleSerializer.new(puzzle).as_json
    end

    render json: {
      puzzles: serialized_puzzles,
    }
  end

  def destroy
    # TODO: only admins should have permission to this action

    @puzzle.destroy!

    render json: PuzzleSerializer.new(@puzzle).as_json
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
