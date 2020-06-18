class User < ApplicationRecord
  has_paper_trail

  scope :non_devs, -> { where.not(email: [ENV['DEV_EMAIL'], ENV['DEV2_EMAIL'], ENV['DEV3_EMAIL']]) }
end
