class BillableReportPolicy < ApplicationPolicy
  def index?
    user.finance? || super
  end
end
