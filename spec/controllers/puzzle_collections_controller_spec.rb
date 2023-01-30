require 'rails_helper'

describe 'PuzzleCollections', type: :request do
  let(:user) { create(:user) }
  let(:admin_user) { create(:user, admin: true) }
  let(:puzzle) { create(:puzzle) }
  let(:puzzle_collection) { create(:puzzle_collection) }

  describe 'destroy' do
    it 'returns a permission error if normal user', :error_response do
      delete_api "/api/puzzle_collections/#{puzzle_collection.id}", {}, user

      expect(response).to have_http_status(403)
    end

    it 'deletes the puzzle collection if admin user' do
      puzzle.update!(source_collection_id: puzzle_collection.id)
      expect(puzzle.puzzle_collections_puzzles.count).to eq 1

      delete_api "/api/puzzle_collections/#{puzzle_collection.id}", {}, admin_user

      puzzle.reload
      expect(PuzzleCollection.count).to eq 0
      expect(puzzle.puzzle_collections_puzzles.count).to eq 0
      expect(puzzle.source_collection_id).to be_nil
    end
  end
end
