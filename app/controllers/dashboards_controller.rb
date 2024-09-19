class DashboardsController < ApplicationController
  def show
    authorize :dashboard
    @report = DashboardAggregator.new.overview
  end

  def status_overview
    authorize :dashboard, :show?
    @report = DashboardAggregator.new.status_overview
  end

  def sync_overview
    authorize :dashboard, :show?
    @report = DashboardAggregator.new.sync_overview
  end

  def instance_overview
    authorize :dashboard, :show?
    @report = DashboardAggregator.new.organization_overview
  end
end
