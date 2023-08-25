class OrganizationPolicy < ApplicationPolicy
  attr_reader :user

  def initialize(user, _record)
    @user = user
  end

  def restore?
    user.admin?
  end

  def destroy?
    user.admin?
  end
end
