# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user.admin? || user.editor? || user.viewer?
  end

  def create?
    user.admin? || user.editor?
  end

  alias new? create?
  alias edit? create?
  alias update? create?
  alias destroy? create?

  alias show? index?

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NotImplementedError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end
end
