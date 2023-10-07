class ReleaseNotePolicy < ApplicationPolicy
  def publish?
    !record.published? && (user.admin? || user.editor?)
  end

  def new?
    user.admin? || user.editor?
  end

  alias eidt? publish?
  alias update? publish?
end
