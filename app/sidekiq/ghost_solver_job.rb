class GhostSolverJob
  include Sidekiq::Job

  MIN_RUN_SECONDS = 30

  def perform
    start_time = Time.now
    while Time.now - start_time < MIN_RUN_SECONDS
      replay_solution
      sleep 2
    end
  end

  private

  def replay_solution
    all_solutions = UserSolution.cached_all
    user_solution = all_solutions.sample

    return 1000 if user_solution.blank?

    id = "ghost_#{user_solution.puzzle_id}_#{SecureRandom.urlsafe_base64(2)}"
    solved = false
    selected_cells = []
    puzzle = user_solution.puzzle
    grid_size = puzzle.constraints['grid_size']
    grid = Array.new(grid_size) { Array.new(grid_size) }
    notes = Array.new(grid_size) { Array.new(grid_size) { [] } }
    tv_puzzle = {
      id: id,
      grid: grid,
      notes: notes,
      selected_cells: selected_cells,
      solved: solved,
      updated_at: Time.now.iso8601,
      created_at: Time.now.iso8601,
      **puzzle.slice(:constraints, :variant, :difficulty),
    }
    broadcast_update(tv_puzzle)

    last_time = 0
    user_solution.steps.each do |step|
      crt_time = step['time']
      delay_time = (crt_time - last_time).clamp(0.5, 10)
      last_time = crt_time
      sleep delay_time

      type, cells, value = step.values_at('type', 'cells', 'value')

      # smooth transition from previous data
      if cells.blank?
        cells = [ step['cell'] ]
      end

      cells.each do |cell|
        row, col = cell.values_at('row', 'col')
        if type == 'note'
          if notes[row][col].include?(value)
            notes[row][col].delete(value)
          else
            notes[row][col] << value
          end
        elsif type == 'delete'
          grid[row][col] = nil
          notes[row][col] = []
        elsif type == 'digit'
          grid[row][col] = value
        end
      end

      tv_puzzle[:selected_cells] = cells
      broadcast_update(tv_puzzle)
    end

    tv_puzzle[:solved] = true
    broadcast_update(tv_puzzle)

    sleep 10

    broadcast_remove(id)
  end

  def broadcast_update(tv_puzzle)
    tv_puzzle[:updated_at] = Time.now.iso8601
    ActionCable.server.broadcast(TvChannel::CHANNEL_NAME, {
      type: TvChannel::MESSAGE_TYPES[:puzzle_update],
      data: tv_puzzle,
    })
  end

  def broadcast_remove(id)
    puzzle_remove_message = {
      type: TvChannel::MESSAGE_TYPES[:puzzle_remove],
      data: [ id ],
    }
    ActionCable.server.broadcast(TvChannel::CHANNEL_NAME, puzzle_remove_message)
  end
end
