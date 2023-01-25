class Api::PuzzlesController < ApplicationController
  before_action :authenticate_user!, only: %i[index create destroy group_counts]
  before_action :load_puzzle, only: %i[show check destroy]

  def random
    authorize! :read, Puzzle

    all_puzzle_ids = Puzzle.all_ids(puzzle_filters)

    puzzle_ids = all_puzzle_ids - params[:id_blacklist]

    puzzle = if puzzle_ids.present?
      random_index = rand(puzzle_ids.size)
      puzzle_id = puzzle_ids[random_index]
      Puzzle.find_by(public_id: puzzle_id)
    end

    if puzzle.blank?
      unless current_user&.admin?
        Honeybadger.notify("Category #{puzzle_filters[:variant]} #{puzzle_filters[:difficulty]} fully solved")
      end
      render json: {}, status: :not_found
      return
    end

    render json: PuzzleSerializer.new(puzzle).as_json
  end

  def show
    authorize! :read, @puzzle

    render json: PuzzleSerializer.new(@puzzle).as_json
  end

  def check
    params.require(:grid)

    correct = @puzzle.solution == params[:grid]

    if correct
      Honeybadger.notify("Someone solved puzzle #{@puzzle.public_id}!")
    end

    render json: {
      correct: correct,
    }
  end

  def create
    authorize! :create, Puzzle
    # TODO: check that there isn't a identical/similar puzzle

    puzzle = Puzzle.new(puzzle_params)
    if puzzle.save
      puzzle.invalidate_puzzle_cache
      render json: PuzzleSerializer.new(puzzle).as_json
    else
      render json: {
        errors: puzzle.errors.messages,
      }, status: :bad_request
    end
  end

  def index
    authorize! :read_all, Puzzle

    serialized_puzzles = Puzzle.order(:id).map do |puzzle|
      PuzzleSerializer.new(puzzle).as_json
    end

    render json: {
      puzzles: serialized_puzzles,
    }
  end

  def destroy
    authorize! :manage, @puzzle

    @puzzle.destroy!
    @puzzle.invalidate_puzzle_cache

    render json: PuzzleSerializer.new(@puzzle).as_json
  end

  def group_counts
    authorize! :read_all, Puzzle

    group_counts = Puzzle.group(:variant, :difficulty).order(:variant, :difficulty).count

    Puzzle.variants.keys.each do |variant|
      Puzzle.difficulties.keys.each do |difficulty|
        key = [ variant, difficulty ]
        group_counts[key] ||= 0
      end
    end

    serialized_group_counts = group_counts.map do |key, count|
      {
        variant: key[0],
        difficulty: key[1],
        count: count,
      }
    end

    render json: {
      group_counts: serialized_group_counts,
    }
  end

  private

  def load_puzzle
    @puzzle = Puzzle.where(public_id: params[:id]).sole
  end

  def puzzle_filters
    params.require([:variant, :difficulty])
    {
      variant: params[:variant],
      difficulty: params[:difficulty],
    }
  end

  def puzzle_params
    # permit doesn't work with nested arrays :-/
    params.require(:puzzle).permit!
    params.require(:puzzle).to_h.slice(
      :constraints, :variant, :difficulty, :solution, :source_name, :source_url
    )
  end
end
