class Organization < ApplicationRecord
  SUPPORTED_LANGUAGES = {
    en: 'English',
    km: 'Khmer',
    my: 'Burmese'
  }.freeze

  mount_uploader :logo, ImageUploader

  validates :logo, presence: true
  validates :full_name, :short_name, presence: true
  validates :short_name, uniqueness: { case_sensitive: false }, format: { with: %r{\A[a-z](?:[a-z0-9-]*[a-z0-9])?\z}i }, length: { in: 1..63 }

  class << self
    def current
      find_by(short_name: Apartment::Tenant.current)
    end

    def switch_to(tenant_name)
      Apartment::Tenant.switch!(tenant_name)
    end
  end

  def save_and_load_generic_data
    return false if invalid?

    response = HTTParty.post("http://localhost:3000/api/v1/organizations", headers: { Authorization: "Token token=#{current_admin_user&.token}" })
  end
end
