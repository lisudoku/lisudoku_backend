require 'rails_helper'

describe 'Puzzles', type: :request do
  let(:user) { create(:user) }
  let(:admin_user) { create(:user, admin: true) }
  let(:puzzle) { create(:puzzle) }
  let(:puzzle_collection) { create(:puzzle_collection) }
  let(:other_puzzle_collection) { create(:puzzle_collection) }

  describe 'show' do
    it 'returns a serialized puzzle if valid id' do
      get_api "/api/puzzles/#{puzzle.public_id}"

      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body['public_id']).to eq(puzzle.public_id)
      expect(body['variant']).to eq(puzzle.variant)
      expect(body['difficulty']).to eq(puzzle.difficulty)
      expect(body['constraints']['grid_size']).to eq(puzzle.constraints['grid_size'])
    end

    it 'returns 404 if invalid id', :error_response do
      get_api "/api/puzzles/#{puzzle.public_id + 'h4ck3r'}"

      expect(response).to have_http_status(404)
    end
  end

  describe 'index' do
    it 'returns a permission error if normal user', :error_response do
      get_api '/api/puzzles', user

      expect(response).to have_http_status(403)
    end

    it 'returns a list of serialized puzzles if admin user' do
      puzzle
      expect(Puzzle.count).to eq 1

      get_api '/api/puzzles', admin_user

      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body['puzzles'].size).to eq(1)
      expect(body['puzzles'][0]['public_id']).to eq(puzzle.public_id)
    end
  end

  describe 'create' do
    before :each do
      @puzzle_data = {
        puzzle: {
          variant: Puzzle.variants[:classic],
          difficulty: Puzzle.difficulties[:easy4x4],
          constraints: {
            'grid_size': 4,
            'regions': [],
            'fixed_numbers': [],
          },
          solution: [
            [ 2, 1, 4, 3 ],
            [ 3, 4, 1, 2 ],
            [ 1, 2, 3, 4 ],
            [ 4, 3, 2, 1 ]
          ],
          source_collection_id: puzzle_collection.id,
        },
      }
    end

    it 'returns a permission error if normal user', :error_response do
      expect(Puzzle.count).to eq 0
      post_api '/api/puzzles', @puzzle_data, user

      expect(response).to have_http_status(403)
      expect(Puzzle.count).to eq 0
    end

    it 'creates a puzzle if admin user' do
      expect(Puzzle.count).to eq 0

      post_api '/api/puzzles', @puzzle_data, admin_user

      expect(response).to have_http_status(200)
      expect(Puzzle.count).to eq 1
      body = JSON.parse(response.body)
      expect(body['variant']).to eq(@puzzle_data[:puzzle][:variant])
      puzzle = Puzzle.first
      expect(puzzle.variant).to eq(@puzzle_data[:puzzle][:variant])
      expect(puzzle.public_id).to be_present
      expect(puzzle.source_collection_id).to eq(@puzzle_data[:puzzle][:source_collection_id])
      expect(puzzle.puzzle_collections.count).to eq 1
    end
  end

  describe 'destroy' do
    it 'returns a permission error if normal user', :error_response do
      delete_api "/api/puzzles/#{puzzle.id}", {}, user

      expect(response).to have_http_status(403)
    end

    it 'deletes the puzzle if admin user' do
      puzzle
      puzzle_collection.puzzle_collections_puzzles.create!(puzzle: puzzle)
      expect(Puzzle.count).to eq 1
      expect(puzzle_collection.puzzles.count).to eq 1
      expect(PuzzleCollectionsPuzzle.count).to eq 1

      delete_api "/api/puzzles/#{puzzle.id}", {}, admin_user

      expect(response).to have_http_status(200)
      expect(Puzzle.count).to eq 0
      expect(puzzle_collection.puzzles.count).to eq 0
      expect(PuzzleCollectionsPuzzle.count).to eq 0
    end
  end

  describe 'update' do
    it 'returns a permission error if normal user', :error_response do
      data = {
        difficulty: Puzzle.difficulties[:hard9x9],
      }
      patch_api "/api/puzzles/#{puzzle.id}", data, user

      expect(response).to have_http_status(403)
    end

    it 'updates the puzzle if admin user' do
      puzzle
      puzzle.update!(source_collection_id: puzzle_collection.id)
      expect(Puzzle.count).to eq 1
      expect(puzzle_collection.puzzles.count).to eq 1
      expect(other_puzzle_collection.puzzles.count).to eq 0
      expect(PuzzleCollectionsPuzzle.count).to eq 1

      data = {
        difficulty: Puzzle.difficulties[:hard9x9],
        source_collection_id: other_puzzle_collection.id,
      }
      patch_api "/api/puzzles/#{puzzle.id}", data, admin_user

      expect(response).to have_http_status(200)
      expect(Puzzle.count).to eq 1
      expect(Puzzle.first.difficulty).to eq data[:difficulty]
      expect(puzzle_collection.puzzles.count).to eq 0
      expect(other_puzzle_collection.puzzles.count).to eq 1
      expect(PuzzleCollectionsPuzzle.count).to eq 1
    end

    it 'does not double add puzzle to collection' do
      puzzle
      puzzle.puzzle_collections_puzzles.create!(puzzle_collection: puzzle_collection)
      expect(Puzzle.count).to eq 1
      expect(puzzle_collection.puzzles.count).to eq 1
      expect(PuzzleCollectionsPuzzle.count).to eq 1

      data = {
        source_collection_id: puzzle_collection.id,
      }
      patch_api "/api/puzzles/#{puzzle.id}", data, admin_user

      expect(response).to have_http_status(200)
      expect(Puzzle.count).to eq 1
      expect(puzzle_collection.puzzles.count).to eq 1
      expect(PuzzleCollectionsPuzzle.count).to eq 1
    end
  end
end
