# frozen_string_literal: true

class DashboardAggregator
  
  def initialize(filters = {})
    @filters = filters
  end

  def call
    {}.merge(basic_aggregates)
      .merge(child_protection_aggregates)
      .merge(client_risk_assessments_aggregates)
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
end
