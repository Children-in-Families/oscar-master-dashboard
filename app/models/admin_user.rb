class AdminUser < ApplicationRecord
  extend Enumerize

  ROLES = %w[admin editor finance viewer].freeze

  enumerize :role, in: ROLES, default: :viewer, predicates: true

  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, presence: true
  before_create :generate_token

  scope :admins, -> { where(role: :admin) }
  scope :editors, -> { where(role: :editor) }

  def generate_token!
    generate_token
    save
  end

  private

  def generate_token
   self.token = loop do
     random_token = SecureRandom.urlsafe_base64(nil, false)
     break random_token unless self.class.exists?(token: random_token)
   end
  end
end
