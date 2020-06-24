ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { @page_title } do
    div do
      panel 'Filter' do
        render 'admin/instances/filter', url: admin_dashboard_path
      end

      table_for :monthly_usage_report do
        assigns[:data].each do |key, value|
          column key.to_s.titleize do
            value
          end
        end
      end
    end
  end

  controller do
    def index
      @month = params.dig(:report, :month) || Date.current.month
      @year  = params.dig(:report, :year) || Date.current.year

      beginning_of_month = Date.new(@year.to_i, @month.to_i, 1)
      end_of_month = beginning_of_month.end_of_month
      @page_title = "Usage report for #{beginning_of_month.strftime('%B %Y')}"

      report = MonthlyUsageReport.new(beginning_of_month, end_of_month)

      @data = report.aggregate_data_without_dev
    end
  end
end
