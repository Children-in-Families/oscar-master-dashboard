class UsageReportsController < ApplicationController
  def index
    authorize UsageReport

    params[:q] ||= {}
    params[:q][:month_eq] ||= 1.month.ago.month
    params[:q][:year_eq] ||= Date.current.year
    params[:q][:s] ||= "organizations_name ASC"
 
    @q = UsageReport.ransack(params[:q])
    @usage_reports = @q.result.includes(:organization)

    respond_to do |format|
      format.html
      format.xlsx do
        filename = "tmp/usage-report-#{Date.today.strftime("%Y-%m-%d")}.xlsx"
        UsageReportExportHandler.call(@usage_reports, params[:q][:month_eq], params[:q][:year_eq], filename)
        send_file filename, disposition: :attachment
      end
    end
  end

  def dashboard
    authorize UsageReport

    params[:q] ||= {}
 
    @q = Organization.without_shared.active.ransack(params[:q])
    @chart_engine = ChartDataConverter.new(@q.result)
  end
end
