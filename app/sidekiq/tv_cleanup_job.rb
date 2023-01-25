class TvCleanupJob
  include Sidekiq::Job
  include RedisTv

  def perform
    clean_tv_puzzles
    clean_tv_viewers
  end

  def clean_tv_puzzles
    tv_puzzles = redis_get_puzzles

    expired_tv_puzzle_ids = tv_puzzles.filter_map do |tv_puzzle|
      if tv_puzzle['updated_at'].to_datetime <= 1.minute.ago
        tv_puzzle['id']
      end
    end

    return if expired_tv_puzzle_ids.blank?

    puts "Expired tv puzzles: #{expired_tv_puzzle_ids}"

    redis_remove_puzzles(expired_tv_puzzle_ids)

    puzzle_remove_message = {
      type: TvChannel::MESSAGE_TYPES[:puzzle_remove],
      data: expired_tv_puzzle_ids,
    }
    ActionCable.server.broadcast(TvChannel::CHANNEL_NAME, puzzle_remove_message)
  end

  def clean_tv_viewers
    tv_viewers = redis_get_viewers

    expired_tv_viewer_ids = tv_viewers.filter_map do |tv_viewer|
      if tv_viewer['updated_at'].nil? || tv_viewer['updated_at'].to_datetime <= 10.minutes.ago
        tv_viewer['id']
      end
    end

    return if expired_tv_viewer_ids.blank?

    puts "Expired tv viewers: #{expired_tv_viewer_ids}"

    redis_remove_viewers(expired_tv_viewer_ids)

    viewer_count_update_message = {
      type: TvChannel::MESSAGE_TYPES[:viewer_count_update],
      data: redis_viewer_count,
    }
    ActionCable.server.broadcast(TvChannel::CHANNEL_NAME, viewer_count_update_message)
  end
end
