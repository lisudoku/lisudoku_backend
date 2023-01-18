require 'rails_helper'

describe 'Puzzles', type: :request do
  let(:user) { create(:user) }
  let(:admin_user) { create(:user, admin: true) }
  let(:puzzle) { create(:puzzle) }

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
    before :all do
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
          source_name: 'Some Source',
          source_url: 'http://www.something.com/puzzles.pdf',
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
      expect(Puzzle.first.variant).to eq(@puzzle_data[:puzzle][:variant])
      expect(Puzzle.first.public_id).to be_present
      expect(Puzzle.first.source_name).to eq(@puzzle_data[:puzzle][:source_name])
      expect(Puzzle.first.source_url).to eq(@puzzle_data[:puzzle][:source_url])
    end
  end

  describe 'destroy' do
    it 'returns a permission error if normal user', :error_response do
      delete_api "/api/puzzles/#{puzzle.public_id}", {}, user

      expect(response).to have_http_status(403)
    end

    it 'deletes the puzzle if admin user' do
      puzzle
      expect(Puzzle.count).to eq 1

      delete_api "/api/puzzles/#{puzzle.public_id}", {}, admin_user

      expect(response).to have_http_status(200)
      expect(Puzzle.count).to eq 0
    end
  end
end
