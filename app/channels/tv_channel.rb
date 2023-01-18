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

  def subscribed
    puts "Subscribed to #{params[:channel]} (user #{user_id})"
    self.is_player = !!params[:is_player]

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
        Honeybadger.notify('Someone is watching!')
      end
      init_data = {
        tv_puzzles: tv_puzzles,
        viewer_count: viewer_count,
      }
      transmit({ type: MESSAGE_TYPES[:init_puzzles], data: init_data })
    end
  end

  def handle_puzzle_update(data)
    puzzle_id = data['puzzle_id']
    id = "#{self.user_id}_#{puzzle_id}"
    grid, notes, selected_cell, solved = data.values_at('grid', 'notes', 'selected_cell', 'solved')
    tv_puzzle = {
      id: id,
      puzzle_id: puzzle_id,
      user_id: self.user_id,
      grid: grid,
      notes: notes,
      selected_cell: selected_cell,
      solved: solved,
      updated_at: Time.now.iso8601,
    }

    unless redis_puzzle_exists?(id)
      puzzle = Puzzle.find_by(public_id: puzzle_id)
      tv_puzzle.merge!({
        created_at: Time.now.iso8601,
        **puzzle.slice(:constraints, :variant, :difficulty),
      })

      if redis_puzzles_count == 0
        Honeybadger.notify('Someone is playing!')
      end
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
