class TrainerPuzzleGeneratorJob
  include Sidekiq::Job

  def perform
    puts 'Processing user_solutions for trainer'

    user_solution_ids = UserSolution.where(processed_by_trainer: false)
      .joins(:puzzle)
      .where('puzzles.variant = ?', Puzzle.variants[:classic])
      .ids

    puts "Found #{user_solution_ids.size} unprocessed user_solutions"

    user_solution_ids.each do |user_solution_id|
      TrainerUserSolutionJob.perform_async(user_solution_id)
    end
  end
end
