class DuplicationPolicy < ApplicationPolicy
  def resolve?
    user.admin?
  end
end
