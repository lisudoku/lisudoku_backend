class Api::AdminController < ApplicationController
  def puzzle_counts
    group_counts = Puzzle.group(:variant, :difficulty).order(:variant, :difficulty).count

    Puzzle.variants.keys.each do |variant|
      Puzzle.difficulties.keys.each do |difficulty|
        key = [ variant, difficulty ]
        group_counts[key] ||= 0
      end
    end

    serialized_group_counts = group_counts.map do |key, count|
      {
        variant: key[0],
        difficulty: key[1],
        count:,
      }
    end

    render json: {
      group_counts: serialized_group_counts,
    }
  end
end
