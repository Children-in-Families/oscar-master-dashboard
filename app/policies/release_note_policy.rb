class ReleaseNotePolicy < ApplicationPolicy
  def publish?
    record.published_at.blank? && (user.admin? || user.editor?)
  end

  def new?
    user.admin? || user.editor?
  end
end
