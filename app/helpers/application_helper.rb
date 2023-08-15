module ApplicationHelper
  def active_class(condition)
    condition ? 'active' : ''
  end
end
