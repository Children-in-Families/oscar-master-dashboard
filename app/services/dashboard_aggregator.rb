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

  private
  
  def basic_aggregates
    query = <<-SQL.squish
      SELECT
        COUNT(*) AS total_cases,
        COUNT(*) FILTER (WHERE status = 'Exited') AS exited,
        COUNT(*) FILTER (WHERE status = 'Accepted') AS accepted,
        COUNT(*) FILTER (WHERE status = 'Active') AS active,
        COUNT(*) FILTER (WHERE status = 'Referred') AS referred,
        COUNT(*) FILTER (WHERE #{IS_MALE}) AS male_count,
        COUNT(*) FILTER (WHERE #{IS_FEMALE}) AS female_count,
        COUNT(*) FILTER (WHERE #{IS_NON_BINARY}) as non_binary_count,
        COUNT(*) FILTER (WHERE #{IS_AGE_18PLUS}) AS age_18_plus,
        COUNT(*) FILTER (WHERE #{IS_AGE_18PLUS} AND #{IS_MALE}) AS age_18_plus_male,
        COUNT(*) FILTER (WHERE #{IS_AGE_18PLUS} AND #{IS_FEMALE}) AS age_18_plus_female,
        COUNT(*) FILTER (WHERE #{IS_AGE_18PLUS} AND #{IS_NON_BINARY}) AS age_18_plus_non_binary,
        COUNT(*) FILTER (WHERE #{IS_AGE_15_17}) AS age_15_17,
        COUNT(*) FILTER (WHERE #{IS_AGE_15_17} AND #{IS_MALE}) AS age_15_17_male,
        COUNT(*) FILTER (WHERE #{IS_AGE_15_17} AND #{IS_FEMALE}) AS age_15_17_female,
        COUNT(*) FILTER (WHERE #{IS_AGE_15_17} AND #{IS_NON_BINARY}) AS age_15_17_non_binary,
        COUNT(*) FILTER (WHERE #{IS_AGE_10_14}) AS age_10_14,
        COUNT(*) FILTER (WHERE #{IS_AGE_10_14} AND #{IS_MALE}) AS age_10_14_male,
        COUNT(*) FILTER (WHERE #{IS_AGE_10_14} AND #{IS_FEMALE}) AS age_10_14_female,
        COUNT(*) FILTER (WHERE #{IS_AGE_10_14} AND #{IS_NON_BINARY}) AS age_10_14_non_binary,
        COUNT(*) FILTER (WHERE #{IS_AGE_5_9}) AS age_5_9,
        COUNT(*) FILTER (WHERE #{IS_AGE_5_9} AND #{IS_MALE}) AS age_5_9_male,
        COUNT(*) FILTER (WHERE #{IS_AGE_5_9} AND #{IS_FEMALE}) AS age_5_9_female,
        COUNT(*) FILTER (WHERE #{IS_AGE_5_9} AND #{IS_NON_BINARY}) AS age_5_9_non_binary,
        COUNT(*) FILTER (WHERE #{IS_AGE_0_4}) AS age_0_4,
        COUNT(*) FILTER (WHERE #{IS_AGE_0_4} AND #{IS_MALE}) AS age_0_4_male,
        COUNT(*) FILTER (WHERE #{IS_AGE_0_4} AND #{IS_FEMALE}) AS age_0_4_female,
        COUNT(*) FILTER (WHERE #{IS_AGE_0_4} AND #{IS_NON_BINARY}) AS age_0_4_non_binary,
        COUNT(*) FILTER (WHERE #{IS_NO_DOB}) AS no_dob,
        COUNT(*) FILTER (WHERE #{IS_NO_DOB} AND #{IS_MALE}) AS no_dob_male,
        COUNT(*) FILTER (WHERE #{IS_NO_DOB} AND #{IS_FEMALE}) AS no_dob_female,
        COUNT(*) FILTER (WHERE #{IS_NO_DOB} AND #{IS_NON_BINARY}) AS no_dob_non_binary
      FROM clients;
    SQL

    ActiveRecord::Base.connection.execute(query).first
  end

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
