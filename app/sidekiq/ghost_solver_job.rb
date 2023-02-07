class GhostSolverJob
  include Sidekiq::Job

  def perform
    start_time = Time.now
    while Time.now - start_time < 100
      replay_solution
      sleep 2
    end
  end

  private

  def replay_solution
    user_solution = UserSolution.all.sample
    return 1000 if user_solution.blank?

    id = "ghost_#{user_solution.puzzle_id}_#{SecureRandom.urlsafe_base64(2)}"
    solved = false
    selected_cell = nil
    puzzle = user_solution.puzzle
    grid_size = puzzle.constraints['grid_size']
    grid = Array.new(grid_size) { Array.new(grid_size) }
    notes = Array.new(grid_size) { Array.new(grid_size) { [] } }
    tv_puzzle = {
      id: id,
      grid: grid,
      notes: notes,
      selected_cell: selected_cell,
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

      type, cell, value = step.values_at('type', 'cell', 'value')
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

      tv_puzzle[:selected_cell] = cell
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
