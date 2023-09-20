class BillableReportExportHandler
  include ApplicationHelper

  def self.call(report, file_name)
    new(report, file_name).call
  end

  attr_reader :report, :file_name

  def initialize(report, file_name)
    @report = report
    @file_name = file_name
  end

  
  def call
    Organization.switch_to(report.organization.short_name)

    Axlsx::Package.new do |p|
      add_client_sheet(p)
      add_family_sheet(p)
      
      p.serialize(file_name)
    end
  end

  private

  def add_client_sheet(package)
    headers = [
      'Client ID',
      'Created Date',
      'Accepted/Acitve Date',
      'Billable Status',
      'Current Status',
      'Case Worker'
    ]

    package.workbook.add_worksheet(name: "Billable clients #{ report.month }-#{report.year}") do |sheet|
      sheet.add_row headers
      
      report.billable_report_items.client.includes(:version, :billable).each do |client_item|
        client = client_item.billable
        version = client_item.version

        sheet.add_row [
          client.slug,
          format_value(client.created_at),
          format_value(version.created_at),
          client_item.billable_status,
          client.status,
          client.users.map(&:name).join(', ')
        ]
      end
    end
  end

  def add_family_sheet(package)
    headers = [
      'Fmily ID',
      'Created Date',
      'Accepted/Acitve Date',
      'Billable Status',
      'Current Status',
      'Case Worker'
    ]

    package.workbook.add_worksheet(name: "Billable families #{ report.month }-#{report.year}") do |sheet|
      sheet.add_row headers
      
      report.billable_report_items.family.includes(:version, :billable).each do |family_item|
        family = family_item.billable
        version = family_item.version

        sheet.add_row [
          family.id,
          format_value(family.created_at),
          format_value(version.created_at),
          family_item.billable_status,
          family.status,
          family.case_workers.map(&:name).join(', ')
        ]
      end
    end
  end
end
