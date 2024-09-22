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
    @q ||= DashboardFilter.new(filter_params)
    @report_aggregator ||= DashboardAggregator.new(@q)
  end

  def filter_params
    return {} if params[:dashboard_filter].blank?

    params[:dashboard_filter][:organization_ids] = params[:dashboard_filter][:organization_ids].reject(&:blank?)
    params[:dashboard_filter][:country] = params[:dashboard_filter][:country].reject(&:blank?)

    params.require(:dashboard_filter).permit(
      :organization_integrated,
      :organization_created_at_gteq,
      :organization_created_at_lteq,
      :has_disability,
      :status,
      :initial_referral_date_gteq,
      :initial_referral_date_lteq,
      :created_at_gteq,
      :created_at_lteq,
      province_id: [],
      country: [],
      organization_ids: []
    )
  end
end
