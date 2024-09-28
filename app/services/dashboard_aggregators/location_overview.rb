# frozen_string_literal: true

module DashboardAggregators
  class LocationOverview < Overview
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

      chat_data = organizations.map do |organization|
        Organization.switch_to(organization.short_name)
        case_overview.symbolize_keys
      end.each_with_object({}) do |data_per_org, output|
        data_per_org.each do |key, value|
          output[key] ||= 0
          output[key] += value.to_i
        end
      end

      {
        cambodia: cambodia_data,
        all_ngo_data: all_ngo_data,
        chart_data: {
          case_overview: {
            labels: ['Opening Cases', 'Reaccepting  Cases', 'Closed Cases'],
            datasets: [
              {
                data: [
                  chat_data[:case_overview_opening],
                  chat_data[:reaccepting_cases],
                  chat_data[:case_overview_closed]
                ],
                backgroundColor: ['#1ab394', '#23c6c8', '#c72132'],
                hoverBackgroundColor: ['#1ab394', '#23c6c8', '#c72132']
              }
            ]
          }
        }
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
