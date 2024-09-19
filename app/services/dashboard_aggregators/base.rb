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

    
    def initialize(filters = {})
      @filters = filters
    end
  
    private

    attr_reader :filters

    def organizations
      query = "1 = 1"
      query += " AND organizations.created_at >= '#{filters[:organization_created_at_gteq]}'" if filters[:organization_created_at_gteq].present?
      query += " AND organizations.created_at <= '#{filters[:organization_created_at_lteq]}'" if filters[:organization_created_at_lteq].present?
      query += " AND organizations.integrated = #{filters[:organization_integrated]}" if filters[:organization_integrated].present?
      query += " AND organizations.id IN (#{filters[:organization_ids].join(',')})" if filters[:organization_ids].present?
      query += " AND organizations.country IN (#{filters[:country].map { |c| "'#{c}'" }.join(',')})" if filters[:country].present?

      Organization.where(query)
    end

    def client_filters
      query = "1 = 1"
      # query += " AND clients.status = '#{filters[:status]}'" if filters[:status].present?
      # query += " AND clients.has_disability = #{filters[:has_disability]}" if filters[:has_disability].present?
      query += " AND clients.created_at >= '#{filters[:created_at_gteq]}'" if filters[:created_at_gteq].present?
      query += " AND clients.created_at <= '#{filters[:created_at_lteq]}'" if filters[:created_at_lteq].present?
      query += " AND clients.initial_referral_date >= '#{filters[:initial_referral_date_gteq]}'" if filters[:initial_referral_date_gteq].present?
      query += " AND clients.initial_referral_date <= '#{filters[:initial_referral_date_lteq]}'" if filters[:initial_referral_date_lteq].present?

      query
    end
  end
end
