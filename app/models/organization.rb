require "httparty"

class Organization < ApplicationRecord
  include HTTParty
  default_options.update(verify: false, timeout: 120)

  acts_as_paranoid

  SUPPORTED_LANGUAGES = {
    en: "English",
    km: "Khmer",
    my: "Burmese",
    id: "Bahasa",
    th: "Thailand",
    vn: "Vietnamese"
  }.freeze

  EXPORTABLE_COLUMNS = [
    :full_name,
    :short_name,
    :country,
    :clients_count,
    :referred_count,
    :accepted_client,
    :active_client,
    :exited_client,
    :users_count,
    :referral_source_category_name,
    :supported_languages,
    :demo,
    :created_at
  ].freeze

  SUPPORTED_COUNTRY = ["cambodia", "myanmar", "thailand", "indonesia", "lesotho", "nepal", "haiti", "vietnam"].freeze
  REFERRAL_SOURCES = ["ក្រសួង សអយ/មន្ទីរ សអយ", "អង្គការមិនមែនរដ្ឋាភិបាល", "មន្ទីរពេទ្យ", "នគរបាល", "តុលាការ/ប្រព័ន្ធយុត្តិធម៌", "រកឃើញនៅតាមទីសាធារណៈ", "ស្ថាប័នរដ្ឋ", "មណ្ឌលថែទាំបណ្ដោះអាសន្ន", "ទូរស័ព្ទទាន់ហេតុការណ៍", "មកដោយខ្លួនឯង", "គ្រួសារ", "មិត្តភក្ដិ", "អាជ្ញាធរដែនដី", "ផ្សេងៗ", "សហគមន៍", "ព្រះវិហារ", "MoSVY External System"].freeze

  mount_uploader :logo, ImageUploader

  has_many :global_identity_organizations, dependent: :destroy
  has_many :usage_reports

  before_save :clean_supported_languages, if: :supported_languages?

  validates :supported_languages, presence: true
  validates :logo, presence: true, on: :create
  validates :full_name, :short_name, :referral_source_category_name, presence: true

  # This regex will match any string that starts with a lowercase letter, followed by any number of lowercase letters, digits, underscores. This is based on the rules for postgres identifiers, which state that:
  # -  An identifier can contain only ASCII letters, digits, underscores, and dollar signs.
  # -  An identifier must begin with a letter or an underscore. A letter is an ASCII character in the range a-z or A-Z. The lower case letters are mapped to upper case when stored.
  # -  The maximum length of an identifier is 63 characters.
  # Anyway, we remove support for leading underscores, digits and dollar signs, and enforce a minimum length of 1 character.
  validates :short_name, uniqueness: { case_sensitive: false }, format: { with: /\A[a-z][a-z_]*\z/ }, length: { in: 1..63 }

  scope :demo, -> { where(demo: true) }
  scope :non_demo, -> { where.not(demo: true) }
  scope :without_shared, -> { where.not(short_name: "shared") }
  scope :active, -> { where(onboarding_status: 'completed') }

  # Replacement for only_deleted which is not working with apartment gem
  scope :archived, -> { unscoped { Organization.where.not(deleted_at: nil) } }

  scope :km, -> { where("array_to_string(supported_languages, ',') LIKE (?)", "%km%") }
  scope :en, -> { where("array_to_string(supported_languages, ',') LIKE (?)", "%en%") }
  scope :my, -> { where("array_to_string(supported_languages, ',') LIKE (?)", "%my%") }
  scope :international, -> { where.not(country: 'cambodia') }
  scope :cambodia, -> { where(country: 'cambodia') }
  scope :id, -> { where("array_to_string(supported_languages, ',') LIKE (?)", "%id%") }
  scope :th, -> { where("array_to_string(supported_languages, ',') LIKE (?)", "%th%") }

  before_destroy :deletable?, prepend: true

  ransacker :created_date do
    Arel.sql('date(organizations.created_at)')
  end

  class << self
    def current
      find_by(short_name: Apartment::Tenant.current)
    end

    def switch_to(tenant_name)
      Apartment::Tenant.switch!(tenant_name)
    end

    def update_cache
      find_each do |organization|
        organization.cache_count(reload: true)
      end
    end
  end

  def cache_count(reload: false)
    Organization.switch_to(short_name)
    puts "Organization.switch_to(short_name) #{short_name}"

    Rails.cache.fetch("#{cache_key_with_version}/count", expires_in: 70.minutes, force: reload) do
      {
        clients_count: Client.reportable.count,
        active_client: Client.reportable.active_status.count,
        accepted_client: Client.reportable.accepted_status.count,
        exited_client: Client.reportable.exited_status.count,
        users_count: User.non_devs.where(deleted_at: nil).count,
        referred_count: Client.reportable.where(status: 'Referred').count,
        adult_male: Client.reportable.adult.male.count,
        adult_female: Client.reportable.adult.female.count,
        child_male: Client.reportable.child.male.count,
        child_female: Client.reportable.child.female.count,
        without_age_nor_gender: Client.reportable.without_age_nor_gender.count,
        cases_synced_to_primero: {
          adult_male: usage_reports.sum { |r| r.synced_cases['adult_male'] },
          adult_female: usage_reports.sum { |r| r.synced_cases['adult_female'] },
          child_male: usage_reports.sum { |r| r.synced_cases['child_male'] },
          child_female: usage_reports.sum { |r| r.synced_cases['child_female'] },
          without_age_nor_gender: usage_reports.sum { |r| r.synced_cases['other'] }
        }
      }
    end
  rescue ActiveRecord::StatementInvalid
    # This instance isn't properly onboarded, skip it
    {
        clients_count: 0,
        active_client: 0,
        accepted_client: 0,
        exited_client: 0,
        users_count: 0,
        referred_count: 0,
        adult_male: 0,
        adult_female: 0,
        child_male: 0,
        child_female: 0,
        without_age_nor_gender: 0,
        cases_synced_to_primero: {
          adult_male: 0,
          adult_female: 0,
          child_male: 0,
          child_female: 0,
          without_age_nor_gender: 0
        }
      }
  end

  def display_supported_languages
    supported_languages.map { |lang| SUPPORTED_LANGUAGES[lang.to_sym] }.to_sentence
  end

  def demo_status
    "YES" if demo?
  end

  def clean_supported_languages
    self.supported_languages = supported_languages.select(&:present?)
  end

  # Monitoring and Evaluation Dashboard
  def mande?
    short_name == "mande"
  end

  def shared?
    short_name == "shared"
  end

  def deletable?
    !mande? && !shared? && clients_count.zero?
  end
end
