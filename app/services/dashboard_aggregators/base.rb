# frozen_string_literal: true

module DashboardAggregators
  class Base
    IS_MALE = "gender = 'male'"
    IS_FEMALE = "gender = 'female'"
    IS_NON_BINARY = "gender NOT IN ('male', 'female')"

    IS_ACCEPTED_OR_ACTIVE = "status IN ('Accepted', 'Active')"

    REFERRED_TO_PRIMERO = "referred_to = 'MoSVY External System'"
    REFERRED_FROM_PRIMERO = "referred_from = 'MoSVY External System'"
    
    IS_CHILD = 'EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) < 18'
    IS_AGE_18PLUS = 'EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) >= 18'
    IS_AGE_15_17 = 'EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 15 AND 17'
    IS_AGE_10_14 = 'EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 10 AND 14'
    IS_AGE_5_9 = 'EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 5 AND 9'
    IS_AGE_0_4 = 'EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 0 AND 4'
    IS_NO_DOB = 'date_of_birth IS NULL'

    delegate :organizations, :client_query, :disability_query,
      :joined_province_query, :province_query,
      :status_query, :referral_query, to: :filter
    
    def initialize(filter)
      @filter = filter
    end
  
    private

    def rejected_case
      query = <<-SQL.squish
        SELECT
          COUNT(*) FILTER (WHERE status = 'Exited') AS rejected_case
        FROM clients
        LEFT JOIN enter_ngos ON enter_ngos.client_id = clients.id
        #{disability_query}
        #{joined_province_query}
        WHERE enter_ngos.id IS NULL AND #{client_query}
      SQL

      ActiveRecord::Base.connection.execute(query).first || {}
    end

    attr_reader :filter
  end
end
