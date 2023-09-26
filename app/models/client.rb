class Client < ActiveRecord::Base
  acts_as_paranoid

  has_many :referrals
  has_many :shared_clients, foreign_key: :slug, primary_key: :slug

  has_many :case_worker_clients, dependent: :destroy
  has_many :users, through: :case_worker_clients, validate: false
  
  scope :accepted,               ->        { where(state: 'accepted') }
  scope :rejected,               ->        { where(state: 'rejected') }

  scope :male,                   ->        { joins(:shared_clients).where('shared.shared_clients.gender = ?', 'male') }
  scope :female,                 ->        { joins(:shared_clients).where('shared.shared_clients.gender = ?', 'female') }
  scope :non_binary,             ->        { joins(:shared_clients).where('shared.shared_clients.gender NOT IN (?)', %w(male female)) }

  scope :active_status,          ->        { where(status: 'Active') }
  scope :accepted_status,        ->        { where(status: 'Accepted') }
  scope :exited_status,          ->        { where(status: 'Exited') }
  scope :reportable,             ->        { where(for_testing: false) }
  # scope :reportable,             ->        { with_deleted.where(for_testing: false) }
  scope :adult,                  ->        { where("(EXTRACT(year FROM age(current_date, clients.date_of_birth)) :: int) >= ?", 18) }
  scope :child,                  ->        { where("(EXTRACT(year FROM age(current_date, clients.date_of_birth)) :: int) < ?", 18) }
  scope :without_age_nor_gender, ->        { non_binary.where(date_of_birth: nil) }
end
