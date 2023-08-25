class UsageReportPolicy < ApplicationPolicy
  def export?
    user.admin? || user.editor?
  end
end
