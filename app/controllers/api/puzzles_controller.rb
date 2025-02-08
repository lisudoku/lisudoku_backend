class Api::PuzzlesController < ApplicationController
  before_action :authenticate_user!, only: %i[index create destroy update group_counts]
  before_action :load_puzzle, only: %i[show check]
  load_resource only: %i[update destroy]

  def random
    authorize! :read, Puzzle

    $PUZZLE_RANDOM_COUNTER.increment(labels: {
      variant: params[:variant],
      difficulty: params[:difficulty],
    })
    logger.info "User requested random puzzle (#{params[:variant]},#{params[:difficulty]})"

    all_puzzle_ids = Puzzle.all_ids(puzzle_filters)
    puzzle_ids_blacklist = params.fetch(:id_blacklist, [])

    if !current_user&.admin? &&
       puzzle_ids_blacklist.size > 0 &&
       (puzzle_ids_blacklist.size < 5 || puzzle_ids_blacklist.size % 5 == 0)
      Honeybadger.notify(
        "User has #{puzzle_ids_blacklist.size} solved puzzles",
        error_class: 'User solve count'
      )
    end

    puzzle_ids = all_puzzle_ids - puzzle_ids_blacklist

    puzzle = if puzzle_ids.present?
      puzzle_id = puzzle_ids.sample
      Puzzle.find_by(public_id: puzzle_id)
    end

    if puzzle.blank?
      unless current_user&.admin? ||
             (
               puzzle_filters[:variant] == Puzzle.variants[:antiking] &&
               puzzle_filters[:difficulty] == Puzzle.difficulties[:easy4x4]
             )
        Honeybadger.notify(
          "Category #{puzzle_filters[:variant]} #{puzzle_filters[:difficulty]} fully solved",
          error_class: 'Category fully solved'
        )
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
    stats = nil
    user_solution = nil

    if correct
      $PUZZLE_SOLVED_COUNTER.increment(labels: {
        variant: @puzzle.variant,
        difficulty: @puzzle.difficulty,
      })
      Honeybadger.notify(
        "Someone solved puzzle #{@puzzle.public_id} (#{@puzzle.variant}, #{@puzzle.difficulty})",
        error_class: 'Solved puzzle'
      )
      logger.info "User solved puzzle #{@puzzle.public_id} (#{@puzzle.variant}, #{@puzzle.difficulty})"

      actions = params.permit(actions: [:type, :value, :time, cells: [:row, :col]]).to_h[:actions]
      solve_time = actions.last['time']
      if actions.size > 5000
        actions = nil
        Honeybadger.notify(error_class: 'Too many actions!')
      end

      # Use -1 because ties are considered worse
      stats_query = @puzzle.user_solutions.select(
        "PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY solve_time) as median,
        COUNT(*) as cnt,
        percent_rank(#{solve_time.to_i - 1}) WITHIN GROUP(ORDER BY solve_time DESC) as rank"
      )[0]

      stats = {
        median: stats_query.median,
        count: stats_query.cnt + 1,
        rank: (stats_query.rank * 100).round,
      }

      if stats[:count] == 1
        stats[:rank] = 100
        stats[:median] = solve_time
      end

      user_solution = @puzzle.user_solutions.create!(steps: actions, solve_time: solve_time)
    else
      # This point should not be reached because we check if the solution is correct locally
      Honeybadger.notify(
        "Incorrect puzzle! #{@puzzle.public_id} (#{@puzzle.variant}, #{@puzzle.difficulty}) #{params[:grid]}",
        error_class: 'Incorrect puzzle'
      )
    end

    render json: {
      correct: correct,
      stats: stats,
      user_solution: user_solution.present? ? UserSolutionSerializer.new(user_solution).as_json : nil,
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

    puzzles = Puzzle.order(:id)
    if params[:id].present?
      puzzles = puzzles.where(id: params[:id])
    end

    solved_puzzle_ids = UserSolution.cached_puzzle_ids
    serialized_puzzles = puzzles.map do |puzzle|
      PuzzleSerializer.new(puzzle, { solved_puzzle_ids: solved_puzzle_ids }).as_json
    end

    render json: {
      puzzles: serialized_puzzles,
    }
  end

  # Download puzzles for offline play
  def download
    authorize! :read, Puzzle

    puzzle_ids_blacklist = params.fetch(:id_blacklist, []).to_set
    unsolved_puzzles = Puzzle.cached_all.reject{|p| puzzle_ids_blacklist.include?(p.public_id)}

    puzzles = unsolved_puzzles.group_by{|p| [p.variant, p.difficulty]}.flat_map do |group, group_puzzles|
      variant, difficulty = group
      count = if variant == Puzzle.variants[:classic]
        difficulty == Puzzle.difficulties[:easy9x9] ? 30 : 7
      else
        2
      end
      group_puzzles.sample(count)
    end

    serialized_puzzles = puzzles.map do |puzzle|
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

  def update
    authorize! :manage, @puzzle

    @puzzle.assign_attributes(puzzle_update_filters)

    if @puzzle.save
      render json: PuzzleSerializer.new(@puzzle).as_json
    else
      render json: {
        errors: @puzzle.errors.messages,
      }, status: :bad_request
    end
  end

  def group_counts
    authorize! :read_all, Puzzle

    puzzle_group_counts = Puzzle.group(:variant, :difficulty).order(:variant, :difficulty).count
    Puzzle.variants.keys.product(Puzzle.difficulties.keys).each do |key|
      puzzle_group_counts[key] ||= 0
    end

    solved_group_counts = UserSolution.joins(:puzzle).group(:variant, :difficulty).distinct.count(:puzzle_id)

    serialized_group_counts = puzzle_group_counts.map do |key, count|
      {
        variant: key[0],
        difficulty: key[1],
        puzzle_count: count,
        solve_count: solved_group_counts[key] || 0,
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
      :constraints, :variant, :difficulty, :solution, :source_collection_id, :author
    )
  end

  def puzzle_update_filters
    params.require(:puzzle).permit(:difficulty, :source_collection_id)
  end
end
