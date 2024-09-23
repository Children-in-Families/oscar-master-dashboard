class Service < ActiveRecord::Base
  acts_as_paranoid
  has_many :children, class_name: 'Service', foreign_key: 'parent_id', dependent: :destroy
end
