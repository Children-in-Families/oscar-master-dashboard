class BillableReport < ActiveRecord::Base
  belongs_to :organization

  validates :organization, presence: true
  validates :year, presence: true
  validates :month, presence: true, uniqueness: { scope: [:organization_id, :year] }

  has_many :billable_report_items
  has_many :billable_clients, -> { joins(:version).where(versions: { item_type: 'Client' }) }, class_name: 'BillableReportItem'
  has_many :billable_families, -> { joins(:version).where(version: { item_type: 'Family' }) }, class_name: 'BillableReportItem'
end
