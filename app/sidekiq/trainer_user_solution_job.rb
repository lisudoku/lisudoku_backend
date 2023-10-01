class TrainerUserSolutionJob
  include Sidekiq::Job

  GENERATOR_PATH = ENV.fetch('TRAINER_GENERATOR_PATH', './vendor/lisudoku_puzzler')
  TECHNIQUES = %w[NakedSingle HiddenSingle singles]

  def perform(user_solution_id)
    puts "Processing user_solution #{user_solution_id}"

    user_solution = UserSolution.find(user_solution_id)

    process_user_solution(user_solution)

    puts "Processed user_solution #{user_solution_id}"
  end

  def process_user_solution(user_solution)
    trainer_puzzles = TECHNIQUES.flat_map do |technique|
      process_user_solution_with_technique(user_solution, technique)
    end
    if trainer_puzzles.size == 0
      puts "Generated no grids, stopping"
    else
      puts "Generated #{trainer_puzzles.size} grids, attempting to insert them"
      ids = TrainerPuzzle.insert_all(trainer_puzzles)
      puts "Inserted #{ids.length} trainer puzzles"
      Honeybadger.notify(
        "Generated and inserted #{ids.length} trainer puzzles (user_solution #{user_solution.id}, puzzle #{user_solution.puzzle_id})",
        error_class: 'Trainer new puzzles'
      )
    end
    user_solution.update!(processed_by_trainer: true)
  end

  def process_user_solution_with_technique(user_solution, technique)
    initial_grid_str = user_solution.puzzle.initial_grid_string
    user_solution_steps_str = user_solution.steps.to_json
    command = "#{GENERATOR_PATH} #{initial_grid_str} #{technique} '#{user_solution_steps_str}'"
    puts "Running command with technique #{technique}"
    puts command
    generator = IO.popen(command)
    result_str = generator.gets
    generator.close
    unless result_str&.starts_with?('[')
      puts "Invalid json received from generator #{user_solution.id}"
      Honeybadger.notify(
        "Invalid json received from generator (user_solution #{user_solution.id})",
        error_class: 'Trainer generator error'
      )
      return []
    end
    result_grids = JSON.parse(result_str)
    puts "Received #{result_grids.size} grids from generator"

    result_grids.map do |grid, solutions|
      {
        puzzle_id: user_solution.puzzle_id,
        variant: user_solution.puzzle.variant,
        technique: technique,
        grid: grid,
        solutions: solutions,
      }
    end
  end
end
