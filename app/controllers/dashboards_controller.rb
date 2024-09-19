class DashboardsController < ApplicationController
  def show
    authorize :dashboard
    @report = DashboardAggregator.new.overview
  end

  def status_overview
    authorize :dashboard, :show?
    @report = DashboardAggregator.new.status_overview
  end
end
