class AdminUser < ApplicationRecord
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  before_create :generate_token

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
