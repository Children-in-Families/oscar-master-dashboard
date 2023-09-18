class BillableReport < ActiveRecord::Base
  belongs_to :organization

  validates :organization, presence: true
  validates :year, presence: true
  validates :month, presence: true, uniqueness: { scope: [:organization_id, :year] }

  has_many :billable_report_items
end
