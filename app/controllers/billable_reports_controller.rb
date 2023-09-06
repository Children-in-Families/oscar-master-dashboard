class BillableReportsController < ApplicationController
  def index
    authorize BillableReport

    params[:q] ||= {}
    params[:q][:month_eq] ||= 0.month.ago.month
    params[:q][:year_eq] ||= Date.current.year
    params[:q][:s] ||= "organizations.short_name ASC"
 
    @q = BillableReport.joins(:organization).ransack(params[:q])
    @usage_reports = @q.result.includes(:organization)

    respond_to do |format|
      format.html
      # format.xlsx do
      #   filename = "tmp/usage-report-#{Date.today.strftime("%Y-%m-%d")}.xlsx"
      #   UsageReportExportHandler.call(@usage_reports, params[:q][:month_eq], params[:q][:year_eq], filename)
      #   send_file filename, disposition: :attachment
      # end
    end
  end
end
