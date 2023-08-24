module ApplicationHelper
  def active_class(condition)
    condition ? 'active' : ''
  end

  def bootsnap_alert_class(flass_type)
    case flass_type
    when 'alert'
      'danger'
    when 'notice'
      'success'
    else
      flass_type
    end
  end

  def format_value(value)
    if value.is_a?(Date) || value.is_a?(Time)
      value.strftime('%Y-%m-%d')
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
