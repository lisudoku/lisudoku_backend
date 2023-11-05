class Api::TrainerPuzzlesController < ApplicationController
  load_resource only: %i[check]

  def random
    authorize! :read, TrainerPuzzle

    all_trainer_puzzle_ids = TrainerPuzzle.all_ids(trainer_puzzle_filters)
    trainer_puzzle_ids_blacklist = params.fetch(:id_blacklist, [])

    if trainer_puzzle_ids_blacklist.size > 0 && !current_user&.admin?
      Honeybadger.notify(
        "User has #{trainer_puzzle_ids_blacklist.size} solved trainer puzzles",
        error_class: 'User trainer puzzle solve count'
      )
    end

    trainer_puzzle_ids = all_trainer_puzzle_ids - trainer_puzzle_ids_blacklist

    trainer_puzzle = if trainer_puzzle_ids.present?
      trainer_puzzle_id = trainer_puzzle_ids.sample
      TrainerPuzzle.find_by(id: trainer_puzzle_id)
    end

    if trainer_puzzle.blank?
      unless current_user&.admin?
        Honeybadger.notify(
          "Category #{trainer_puzzle_filters[:variant]} of trainer puzzles fully solved",
          error_class: 'Trainer puzzles fully solved'
        )
      end
      render json: {}, status: :not_found
      return
    end

    render json: TrainerPuzzleSerializer.new(trainer_puzzle).as_json
  end

  def check
    cell = params.require(:cell).permit(:value, position: [:row, :col])

    correct = @trainer_puzzle.solutions.include?(cell)

    unless current_user&.admin?
      Honeybadger.notify(
        "Attempted trainer puzzle #{@trainer_puzzle.id} (#{@trainer_puzzle.technique}, #{@trainer_puzzle.solve_count}) #{correct}",
        error_class: 'Attempted trainer puzzle'
      )
    end

    if correct
      @trainer_puzzle.increment!(:solve_count)
    else
      @trainer_puzzle.increment!(:fail_count)
    end

    render json: {
      correct: correct,
    }
  end

  private

  def trainer_puzzle_filters
    params.require([:variant, :technique])
    {
      variant: params[:variant],
      technique: params[:technique],
    }
  end
end
