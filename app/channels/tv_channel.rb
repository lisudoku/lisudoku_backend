class TvChannel < ApplicationCable::Channel
  include RedisTv

  after_subscribe :send_init_message, unless: :subscription_rejected?

  CHANNEL_NAME = 'tv_channel'

  MESSAGE_TYPES = {
    init_puzzles: 'init_puzzles',
    puzzle_update: 'puzzle_update',
    puzzle_remove: 'puzzle_remove',
  }

  attr_accessor :is_player

  def subscribed
    puts "Subscribed to #{params[:channel]} (user #{user_id})"
    self.is_player = !!params[:is_player]

    unless is_player
      stream_from CHANNEL_NAME
    end
  end

  def unsubscribed
    puts 'Unsubscribed'
    # TODO: if real user, remove puzzles
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
      transmit({ type: MESSAGE_TYPES[:init_puzzles], data: tv_puzzles })
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
    end

    redis_update_puzzle(tv_puzzle)

    puzzle_update_message = {
      type: MESSAGE_TYPES[:puzzle_update],
      data: tv_puzzle,
    }
    ActionCable.server.broadcast(CHANNEL_NAME, puzzle_update_message)
  end
end
