# frozen_string_literal: true

module DashboardAggregators
  class OrganizationOverview < StatusOverview
    def call
      organizations.order(:full_name).map do |organization|
        Organization.switch_to(organization.short_name)
        basic_aggregates
          .merge(disability_aggregates)
          .merge(rejected_case)
          .symbolize_keys
          .merge(
            organization_full_name: organization.full_name,
            organization_short_name: organization.short_name,
            country: organization.country&.titleize
          )
      end
    end

    private

    def disability_aggregates
      query = <<~SQL.squish
        SELECT
          COUNT(clients.id) FILTER (WHERE #{IS_MALE}) AS male_with_disability_count,
          COUNT(clients.id) FILTER (WHERE #{IS_FEMALE}) AS female_with_disability_count,
          COUNT(clients.id) FILTER (WHERE #{IS_NON_BINARY}) AS non_binary_with_disability_count
        FROM clients
        #{joined_province_query}
        JOIN risk_assessments ON clients.id = risk_assessments.client_id AND risk_assessments.has_disability = true AND #{client_query};
      SQL

      ActiveRecord::Base.connection.execute(query).first || {}
    end
  end
end
