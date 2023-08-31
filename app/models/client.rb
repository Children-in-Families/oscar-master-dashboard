class Client < ActiveRecord::Base
  acts_as_paranoid

  has_many :referrals
  
  scope :accepted,               ->        { where(state: 'accepted') }
  scope :rejected,               ->        { where(state: 'rejected') }
  scope :male,                   ->        { where(gender: 'male') }
  scope :female,                 ->        { where(gender: 'female') }
  scope :active_status,          ->        { where(status: 'Active') }
  scope :accepted_status,        ->        { where(status: 'Accepted') }
  scope :exited_status,          ->        { where(status: 'Exited') }
  scope :reportable,             ->        { with_deleted.where(for_testing: false) }
  scope :adult,                  ->        { where("(EXTRACT(year FROM age(current_date, clients.date_of_birth)) :: int) >= ?", 18) }
  scope :child,                  ->        { where("(EXTRACT(year FROM age(current_date, clients.date_of_birth)) :: int) < ?", 18) }
  scope :without_age_nor_gender, ->        { where(date_of_birth: nil).where.not(gender: %w(male female)) }
end
