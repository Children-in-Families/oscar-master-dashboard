class FinancePolicy < ApplicationPolicy
  attr_reader :user

  def initialize(user, _record)
    @user = user
  end

  def index?
    user.finance? || super
  end
end
