class DashboardPolicy < ApplicationPolicy
  attr_reader :user

  def initialize(user, _record)
    @user = user
  end

  def show?
    user.admin? || user.editor?
  end
end
