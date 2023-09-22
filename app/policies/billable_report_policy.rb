class BillableReportPolicy < ApplicationPolicy
  def index?
    return false
    user.finance? || super
  end
end
