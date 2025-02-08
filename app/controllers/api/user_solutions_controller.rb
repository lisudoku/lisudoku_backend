class Api::UserSolutionsController < ApplicationController
  before_action :authenticate_user!, only: %i[index]
  load_resource only: %i[show]

  def index
    authorize! :read, UserSolution

    user_solutions = UserSolution.includes(:puzzle).order(id: :desc).to_a
    serialized_user_solutions = user_solutions.map do |user_solution|
      UserSolutionSerializer.new(user_solution).as_json
    end

    render json: {
      user_solutions: serialized_user_solutions,
    }
  end

  def show
    authorize! :read, @user_solution

    render json: {
      user_solution: UserSolutionSerializer.new(@user_solution).as_json,
      puzzle_constraints: @user_solution.puzzle.constraints,
    }
  end
end
