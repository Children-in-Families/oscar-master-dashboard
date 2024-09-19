class DashboardsController < ApplicationController
  def show
    authorize :dashboard
    @report = report_aggregator.overview
  end

  def status_overview
    authorize :dashboard, :show?
    @report = report_aggregator.status_overview
  end

  def sync_overview
    authorize :dashboard, :show?
    @report = report_aggregator.sync_overview
  end

  def instance_overview
    authorize :dashboard, :show?
    @report = report_aggregator.organization_overview
  end

  def location_overview
    authorize :dashboard, :show?
    @report = report_aggregator.location_overview
  end

  private

  def report_aggregator
    @report_aggregator ||= DashboardAggregator.new
  end
end
