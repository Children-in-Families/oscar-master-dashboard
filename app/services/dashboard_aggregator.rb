# frozen_string_literal: true

class DashboardAggregator
  
  def initialize(filters = {})
    @filters = filters
  end

  def call
    {}.merge(basic_aggregates)
      .merge(child_protection_aggregates)
      .merge(client_risk_assessments_aggregates)
  end

  def overview
    DashboardAggregators::Overview.new(@filters).call
  end

  def status_overview
    DashboardAggregators::StatusOverview.new(@filters).call
  end

  private

  def syncd_primero_aggregates
    query = <<-SQL.squish
      SELECT
        COUNT(*) AS total_synced_primero_cases,
    SQL

    ActiveRecord::Base.connection.execute(query).first
  end

  IS_MALE = "gender = 'male'"
  IS_FEMALE = "gender = 'female'"
  IS_NON_BINARY = "gender NOT IN ('male', 'female')"
  
  IS_CHILD = 'EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) < 18'
  IS_AGE_18PLUS = 'EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) >= 18'
  IS_AGE_15_17 = 'EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 15 AND 17'
  IS_AGE_10_14 = 'EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 10 AND 14'
  IS_AGE_5_9 = 'EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 5 AND 9'
  IS_AGE_0_4 = 'EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 0 AND 4'
  IS_NO_DOB = 'date_of_birth IS NULL'
end
