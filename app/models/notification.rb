class Notification < ActiveRecord::Base
  KEYS = %w(relase_note).freeze

  belongs_to :notifiable, polymorphic: true
  belongs_to :user

  validates :key, presence: true, inclusion: { in: KEYS }, uniqueness: { scope: [:user_id, :notifiable_id, :notifiable_type] }
  validates :user, presence: true
  validates :notifiable, presence: true
end
