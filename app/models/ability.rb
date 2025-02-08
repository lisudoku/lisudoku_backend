# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Puzzle
    can :read, PuzzleCollection
    can :read, Competition
    can :read, TrainerPuzzle
    # Make all solutions public, maybe revisit later
    can :read, UserSolution

    return unless user.present?

    return unless user.admin?

    can :manage, Puzzle
    can :manage, PuzzleCollection
    can :manage, Competition
    can :manage, UserSolution
  end
end
