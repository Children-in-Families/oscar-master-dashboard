class AdminUserPolicy < ApplicationPolicy
  def destroy?
    user.admin?
  end

  def edit?
    user.admin? ||
    (user.editor? && record.role.in?(%w[finance viewer]))
  end

  alias update? edit?
  
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end
