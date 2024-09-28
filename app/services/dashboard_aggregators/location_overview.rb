# frozen_string_literal: true

module DashboardAggregators
  class LocationOverview < Base
    def call
      cambodia_data = organizations.cambodia.map do |organization|
        Organization.switch_to(organization.short_name)
        cambodia_aggregates.symbolize_keys
      end

      all_ngo_data = organizations.map do |organization|
        Organization.switch_to(organization.short_name)
        ngo_aggregates.symbolize_keys.merge(
          country: organization.country
        )
      end

      {
        cambodia: cambodia_data,
        all_ngo_data: all_ngo_data
      }
    end

    private

    def ngo_aggregates
      query = <<~SQL.squish
        SELECT
          COUNT(*) AS total_cases,
          COUNT(*) FILTER (WHERE status = 'Exited') AS case_closed,
          COUNT(*) FILTER (WHERE #{IS_ACCEPTED_OR_ACTIVE}) AS case_opening
        FROM clients
        #{joined_province_query}
        WHERE #{client_query};
      SQL

      ActiveRecord::Base.connection.execute(query).first || {}
    end

    def cambodia_aggregates
      query = <<~SQL.squish
        SELECT
            provinces.name AS province_name,
            COUNT(*) AS total_count,
            COUNT(*) FILTER (WHERE #{IS_MALE}) AS male_count,
            COUNT(*) FILTER (WHERE #{IS_FEMALE}) AS female_count,
            COUNT(*) FILTER (WHERE #{IS_NON_BINARY}) AS non_binary_count
        FROM clients
        JOIN provinces ON provinces.id = clients.province_id AND #{client_query} AND #{status_query} AND #{province_query}
        GROUP BY provinces.id;
      SQL

      ActiveRecord::Base.connection.execute(query).first || {}
    end
  end
end
