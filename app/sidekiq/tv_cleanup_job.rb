class TvCleanupJob
  include Sidekiq::Job
  include RedisTv

  def perform(*args)
    tv_puzzles = redis_get_puzzles

    expired_tv_puzzle_ids = tv_puzzles.filter_map do |tv_puzzle|
      if tv_puzzle['updated_at'].to_datetime <= 1.minute.ago
        tv_puzzle['id']
      end
    end

    return if expired_tv_puzzle_ids.blank?

    puts "Expired puzzles: #{expired_tv_puzzle_ids}"

    redis_remove_puzzles(expired_tv_puzzle_ids)

    puzzle_remove_message = {
      type: TvChannel::MESSAGE_TYPES[:puzzle_remove],
      data: expired_tv_puzzle_ids,
    }
    ActionCable.server.broadcast(TvChannel::CHANNEL_NAME, puzzle_remove_message)
  end
end
