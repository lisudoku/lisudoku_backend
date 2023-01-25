module RedisTv
  REDIS_KEY = 'tv_puzzles'
  REDIS_VIEWERS_KEY = 'viewers'

  def redis_puzzle_exists?(id)
    hash = Kredis.hash REDIS_KEY, typed: :json
    hash[id].present?
  end

  def redis_update_puzzle(tv_puzzle)
    hash = Kredis.hash REDIS_KEY, typed: :json
    id = tv_puzzle[:id]

    hash.update(id => {
      **(hash[id] || {}),
      **tv_puzzle,
    })
  end

  def redis_get_puzzles
    hash = Kredis.hash REDIS_KEY, typed: :json
    hash.values
  end

  def redis_remove_puzzles(tv_puzzle_ids)
    hash = Kredis.hash REDIS_KEY, typed: :json
    tv_puzzle_ids.each do |tv_puzzle_id|
      hash.delete(tv_puzzle_id)
    end
  end

  def redis_puzzles_count
    hash = Kredis.hash REDIS_KEY, typed: :json
    hash.keys.size
  end

  def redis_viewer_count
    viewers = Kredis.hash REDIS_VIEWERS_KEY, typed: :json
    viewers.keys.size
  end

  def redis_add_viewer(user_id)
    viewers = Kredis.hash REDIS_VIEWERS_KEY, typed: :json
    viewers.update(user_id => {
      id: user_id,
      updated_at: DateTime.now.to_s,
    })
  end

  def redis_remove_viewer(user_id)
    viewers = Kredis.hash REDIS_VIEWERS_KEY, typed: :json
    viewers.delete(user_id)
  end

  def redis_get_viewers
    viewers = Kredis.hash REDIS_VIEWERS_KEY, typed: :json
    viewers.values
  end

  def redis_remove_viewers(tv_viewer_ids)
    viewers = Kredis.hash REDIS_VIEWERS_KEY, typed: :json
    tv_viewer_ids.each do |tv_viewer_id|
      viewers.delete(tv_viewer_id)
    end
  end
end
