class Assessment < ActiveRecord::Base
  belongs_to :client

  scope :client_risk_assessments, -> { where.not(level_of_risk: [nil, '']) }
end
