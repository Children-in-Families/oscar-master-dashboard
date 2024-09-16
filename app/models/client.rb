class Client < ActiveRecord::Base
  acts_as_paranoid

  has_many :referrals
  has_many :shared_clients, foreign_key: :slug, primary_key: :slug

  has_many :case_worker_clients, dependent: :destroy
  has_many :users, through: :case_worker_clients, validate: false
  
  has_one :risk_assessment
  
  scope :accepted,               ->        { where(state: 'accepted') }
  scope :rejected,               ->        { where(state: 'rejected') }

  scope :male,                   ->        { joins(:shared_clients).where('shared.shared_clients.gender = ?', 'male') }
  scope :female,                 ->        { joins(:shared_clients).where('shared.shared_clients.gender = ?', 'female') }
  scope :non_binary,             ->        { joins(:shared_clients).where('shared.shared_clients.gender NOT IN (?)', %w(male female)) }

  scope :active_status,          ->        { where(status: 'Active') }
  scope :accepted_status,        ->        { where(status: 'Accepted') }
  scope :exited_status,          ->        { where(status: 'Exited') }
  scope :reportable,             ->        { where(for_testing: false) }
  scope :adult,                  ->        { where("(EXTRACT(year FROM age(current_date, clients.date_of_birth)) :: int) >= ?", 18) }
  scope :child,                  ->        { where("(EXTRACT(year FROM age(current_date, clients.date_of_birth)) :: int) < ?", 18) }
  scope :without_age_nor_gender, ->        { non_binary.where(date_of_birth: nil) }

  scope :accepted_or_active,     ->        { where(status: %w(Accepted Active)) }
  scope :exited,                 ->        { where(status: 'Exited') }

  def self.client_based_aggregates
    query = <<-SQL.squish
      SELECT
        COUNT(*) FILTER (WHERE status = 'Exited') AS exited,
        COUNT(*) FILTER (WHERE status = 'Accepted') AS accepted,
        COUNT(*) FILTER (WHERE status = 'Active') AS active,
        COUNT(*) FILTER (WHERE status = 'Referred') AS referred,
        COUNT(*) FILTER (WHERE gender = 'male') AS male_count,
        COUNT(*) FILTER (WHERE gender = 'female') AS female_count,
        COUNT(*) FILTER (WHERE gender NOT IN ('male', 'female')) as non_binary_count,
        COUNT(*) FILTER (WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) >= 18) AS age_18_plus,
        COUNT(*) FILTER (WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 15 AND 17) AS age_15_17,
        COUNT(*) FILTER (WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 10 AND 14) AS age_10_14,
        COUNT(*) FILTER (WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 5 AND 9) AS age_5_9,
        COUNT(*) FILTER (WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 0 AND 4) AS age_0_4,
        COUNT(*) FILTER (WHERE date_of_birth IS NULL) AS no_dob
      FROM clients;
    SQL

    ActiveRecord::Base.connection.execute(query).first
  end

  def self.client_risk_assessments_aggregates
    query = <<-SQL.squish
      SELECT
        COUNT(*) FILTER (WHERE level_of_risk = 'low') AS risk_low,
        COUNT(*) FILTER (WHERE level_of_risk = 'medium') AS risk_medium,
        COUNT(*) FILTER (WHERE level_of_risk = 'high') AS risk_high,
        COUNT(*) FILTER (WHERE level_of_risk = 'no action') AS risk_no_action
      FROM clients
      JOIN risk_assessments ON clients.id = risk_assessments.client_id;
    SQL

    ActiveRecord::Base.connection.execute(query).first
  end
end
