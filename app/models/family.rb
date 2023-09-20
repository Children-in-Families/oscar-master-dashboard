class Family < ActiveRecord::Base
  has_many :case_worker_families, dependent: :destroy
  has_many :case_workers, through: :case_worker_families, validate: false
end
