# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Puzzle

    return unless user.present?

    return unless user.admin?

    can :manage, Puzzle
  end
end
