class UsageReportsController < ApplicationController
  def show
    params[:q] ||= {}
    params[:q][:month_eq] ||= 1.month.ago.month
    params[:q][:year_eq] ||= Date.current.year
    params[:q][:s] ||= "organizations.short_name ASC"
 
    @q = UsageReport.ransack(params[:q])
    @usage_reports = @q.result.includes(:organization)
  end
end
