class BillableReportPolicy < ApplicationPolicy
  def index?
    return false
    user.finance? || super
  end

  def show?
    true
  end
end
