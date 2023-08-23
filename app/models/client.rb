class Client < ActiveRecord::Base
  acts_as_paranoid
  
  scope :accepted,               ->        { where(state: 'accepted') }
  scope :rejected,               ->        { where(state: 'rejected') }
  scope :male,                   ->        { where(gender: 'male') }
  scope :female,                 ->        { where(gender: 'female') }
  scope :active_status,          ->        { where(status: 'Active') }
  scope :accepted_status,        ->        { where(status: 'Accepted') }
end
