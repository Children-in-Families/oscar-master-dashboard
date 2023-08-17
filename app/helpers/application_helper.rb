module ApplicationHelper
  def active_class(condition)
    condition ? 'active' : ''
  end

  def format_value(value)
    if value.is_a?(Date) || value.is_a?(Time)
      value.strftime('%d/%m/%Y')
    elsif value.is_a?(Array)
      value.join(', ')
    elsif value.is_a?(TrueClass)
      'Yes'
    elsif value.is_a?(FalseClass)
      'No'
    else
      value
    end
  end
end
