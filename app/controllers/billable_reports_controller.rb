class BillableReportsController < ApplicationController
  def index
    authorize BillableReport

    params[:q] ||= {}
    params[:q][:month_eq] ||= 0.month.ago.month
    params[:q][:year_eq] ||= Date.current.year
    params[:q][:s] ||= "organizations.short_name ASC"
 
    @q = BillableReport.ransack(params[:q])
    @usage_reports = @q.result.includes(:organization)

    respond_to do |format|
      format.html
      format.xlsx do
        filename = "tmp/billable-report-#{Date.today.strftime("%Y-%m-%d")}.xlsx"
        Axlsx::Package.new do |p|
          p.workbook.add_worksheet(name: "Billable clients #{ params[:q][:month_eq] }-#{params[:q][:year_eq]}") do |sheet|
            sheet.add_row [
              'Organization full name',
              'Organization short name',
              'Country',
              'Onboarded date',
              'Demo',
              'Billable clients',
              'Billable families',
            ]

            @usage_reports.each do |report|
              sheet.add_row [
                report.organization_name,
                report.organization_short_name,
                report.organization&.country,
                report.organization&.created_at&.strftime('%Y-%m-%d'),
                report.organization&.demo? ? 'Yes' : 'No',
                report.billable_report_items.client.where.not(billable_at: nil).count,
                report.billable_report_items.family.where.not(billable_at: nil).count,
              ]
            end
          end
          
          p.serialize(filename)
        end

        send_file filename, disposition: :attachment
      end
    end
  end

  def show
    respond_to do |format|
      report = BillableReport.find(params[:id])
      authorize report

      format.xlsx do
        filename = "tmp/billable-report-#{report.organization_short_name}-#{Date.today.strftime("%Y-%m-%d")}.xlsx"
        BillableReportExportHandler.call(report, filename)
        send_file filename, disposition: :attachment
      end
    end
  end
end
