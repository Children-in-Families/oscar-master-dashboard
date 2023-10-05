class BillableReportPolicy < ApplicationPolicy
  def index?
    user.finance? || super
  end

  def show?
    true
  end
end
