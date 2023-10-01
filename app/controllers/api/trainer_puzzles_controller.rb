class Api::TrainerPuzzlesController < ApplicationController
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

  private

  def trainer_puzzle_filters
    params.require([:variant, :technique])
    {
      variant: params[:variant],
      technique: params[:technique],
    }
  end
end
