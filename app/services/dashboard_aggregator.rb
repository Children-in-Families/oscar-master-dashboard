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

  def child_protection_aggregates
    query = <<-SQL.squish
      SELECT
        COUNT(DISTINCT clients.id) as child_protection_total,
        COUNT(DISTINCT clients.id) FILTER (WHERE #{IS_MALE}) AS child_protection_male_count,
        COUNT(DISTINCT clients.id) FILTER (WHERE #{IS_FEMALE}) AS child_protection_female_count,
        COUNT(DISTINCT clients.id) FILTER (WHERE #{IS_NON_BINARY}) as child_protection_non_binary_count
      FROM clients
      JOIN client_enrollments ON client_enrollments.client_id = clients.id
      JOIN program_streams ON program_streams.id = client_enrollments.program_stream_id
      JOIN program_stream_services ON program_stream_services.program_stream_id = program_streams.id
      JOIN services ON services.id = program_stream_services.service_id
      WHERE services.name IN ('Family Based Care', 'Drug/Alcohol', 'Anti-Trafficking') AND #{IS_CHILD};
    SQL

    ActiveRecord::Base.connection.execute(query).first
  end

  def client_risk_assessments_aggregates
    query = <<-SQL.squish
      WITH combined_risk_levels AS (
        SELECT
          client_id,
          level_of_risk,
          created_at
        FROM risk_assessments

        UNION ALL

        SELECT
          client_id,
          level_of_risk,
          created_at
        FROM assessments
      ),
      latest_risk_levels AS (
        SELECT DISTINCT ON (client_id)
          client_id,
          level_of_risk
        FROM combined_risk_levels
        WHERE level_of_risk IS NOT NULL AND level_of_risk != ''
        ORDER BY client_id, created_at DESC
      )
      SELECT
        COUNT(*) AS total_risk_assessments,
        COUNT(*) FILTER (WHERE level_of_risk = 'low') AS risk_low,
        COUNT(*) FILTER (WHERE level_of_risk = 'medium') AS risk_medium,
        COUNT(*) FILTER (WHERE level_of_risk = 'high') AS risk_high,
        COUNT(*) FILTER (WHERE level_of_risk = 'no action') AS risk_no_action
      FROM latest_risk_levels
      JOIN clients ON clients.id = latest_risk_levels.client_id;
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
