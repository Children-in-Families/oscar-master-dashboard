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

  def current_province_options
    organizations = Organization.non_demo.active.without_shared.cambodia

    return [] if organizations.blank?

    organizations.map do |organization|
      Organization.switch_to(organization.short_name)
      Province.distinct.pluck(:name)
    end.flatten.uniq.sort
  end

  def link_to_if(condition, name, options = {}, html_options = {}, &block)
    if condition
      link_to(name, options, html_options, &block)
    end
  end
end
