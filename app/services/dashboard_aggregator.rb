# frozen_string_literal: true

class DashboardAggregator
  def initialize(filters = {})
    @filters = filters
  end
  
  def overview
    DashboardAggregators::Overview.new(@filters).call
  end

  def status_overview
    DashboardAggregators::StatusOverview.new(@filters).call
  end

  def sync_overview
    DashboardAggregators::SyncOverview.new(@filters).call
  end

  def organization_overview
    DashboardAggregators::OrganizationOverview.new(@filters).call
  end

  def location_overview
    DashboardAggregators::LocationOverview.new(@filters).call
  end
end
