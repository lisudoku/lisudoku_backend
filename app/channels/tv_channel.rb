class TvChannel < ApplicationCable::Channel
  include RedisTv

  after_subscribe :send_init_message, unless: :subscription_rejected?

  CHANNEL_NAME = 'tv_channel'

  MESSAGE_TYPES = {
    init_puzzles: 'init_puzzles',
    puzzle_update: 'puzzle_update',
    puzzle_remove: 'puzzle_remove',
    viewer_count_update: 'viewer_count_update',
  }

  attr_accessor :is_player

  @@last_wake_at = nil

  def subscribed
    puts "Subscribed to #{params[:channel]} (user #{user_id})"
    self.is_player = !!params[:is_player]

    total_count = redis_viewer_count + redis_puzzles_count
    if total_count > ENV.fetch('TV_MAX_CONNECTIONS', '40').to_i
      Honeybadger.notify("TV connection rejected! player=#{is_player}")
      reject
      return
    end

    unless is_player
      redis_add_viewer(user_id)
      handle_viewer_count_update
      stream_from CHANNEL_NAME
    end
  end

  def unsubscribed
    puts "Unsubscribed (user #{user_id})"
    # TODO: if real user, remove puzzles

    unless is_player
      redis_remove_viewer(user_id)
      handle_viewer_count_update
    end
  end

  def receive(message)
    puts message
    unless self.is_player
      return
    end

    case message['type']
    when MESSAGE_TYPES[:puzzle_update]
      handle_puzzle_update(message['data'])
    end
  end

  private

  def send_init_message
    transmit({ type: '__init__', data: user_id })

    unless self.is_player
      tv_puzzles = redis_get_puzzles
      viewer_count = redis_viewer_count
      if viewer_count == 1
        Honeybadger.notify('Someone is watching!', error_class: 'TV active')
      end
      init_data = {
        tv_puzzles: tv_puzzles,
        viewer_count: viewer_count,
      }

      # Note: tv_puzzles will not contain ghost puzzles because we don't persist them in redis
      if tv_puzzles.empty? && (@@last_wake_at.nil? || @@last_wake_at <= 5.minutes.ago)
        # Wake up ghost solver if someone is watching and no puzzle is playing
        GhostSolverJob.perform_async
        # Also clean up old stuck puzzles (connection still active, but no updates in a while)
        TvCleanupJob.perform_async

        @@last_wake_at = Time.now
      end
      transmit({ type: MESSAGE_TYPES[:init_puzzles], data: init_data })
    end
  end

  def handle_puzzle_update(data)
    puzzle_id = data['puzzle_id']
    id = "#{self.user_id}_#{puzzle_id}"
    grid, cell_marks, selected_cells, solved = data.values_at('grid', 'cell_marks', 'selected_cells', 'solved')

    redis_puzzle = redis_get_puzzle(id)

    tv_puzzle = {
      id: id,
      puzzle_id: puzzle_id,
      user_id: self.user_id,
      grid: grid,
      cell_marks: cell_marks,
      selected_cells: selected_cells,
      solved: solved,
      updated_at: Time.now.iso8601,
      update_count: (redis_puzzle.try(:[], 'update_count') || -1) + 1,
    }

    if redis_puzzle.present?
      if tv_puzzle[:update_count] == 1
        Honeybadger.notify('Someone is playing!', error_class: 'Player active')
      end
    else
      puzzle = Puzzle.find_by(public_id: puzzle_id)
      tv_puzzle.merge!({
        created_at: Time.now.iso8601,
        **puzzle.slice(:constraints, :variant, :difficulty),
      })
    end

    redis_update_puzzle(tv_puzzle)

    puzzle_update_message = {
      type: MESSAGE_TYPES[:puzzle_update],
      data: tv_puzzle,
    }
    ActionCable.server.broadcast(CHANNEL_NAME, puzzle_update_message)
  end

  def handle_viewer_count_update
    # TODO: only send an update once every X updates or seconds
    viewer_count_update_message = {
      type: MESSAGE_TYPES[:viewer_count_update],
      data: redis_viewer_count,
    }
    ActionCable.server.broadcast(CHANNEL_NAME, viewer_count_update_message)
  end
end
