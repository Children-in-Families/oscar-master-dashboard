class BillableReportItem < ActiveRecord::Base
  belongs_to :billable_report
  belongs_to :billable, polymorphic: true, with_deleted: true
  belongs_to :version, class_name: "PaperTrail::Version"

  validates :billable_status, presence: true

  scope :client, -> { where(billable_type: 'Client') }
  scope :family, -> { where(billable_type: 'Family' )}
end
