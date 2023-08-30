class UsageReportPolicy < ApplicationPolicy
  def export?
    user.admin? || user.editor?
  end

  def dashboard?
    index?
  end
end
