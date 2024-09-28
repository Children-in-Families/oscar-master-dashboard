# frozen_string_literal: true

module DashboardAggregators
  class StatusOverview < Base
    def call
      data = organizations.map do |organization|
        Organization.switch_to(organization.short_name)
        basic_aggregates.symbolize_keys
      end.each_with_object({}) do |data_per_org, output|
        data_per_org.each do |key, value|
          output[key] ||= 0
          output[key] += value.to_i
        end
      end

      {
        raw_data: data,
        chart_data: {
          case_by_gender: {
            labels: ['Male', 'Female', 'Other'],
            datasets: [
              {
                data: [
                  data[:male_count],
                  data[:female_count],
                  data[:non_binary_count]
                ],
                backgroundColor: ['#1ab394', '#23c6c8', '#c72132'],
                hoverBackgroundColor: ['#1ab394', '#23c6c8', '#c72132']
              }
            ]
          },
          case_by_age: {
            labels: ['No DoB', '0-4', '5-9', '10-14', '15-17', '18+'],
            datasets: [
              {
                label: 'Male',
                data: data.slice(:no_dob_male, :age_0_4_male, :age_5_9_male, :age_10_14_male, :age_15_17_male, :age_18_plus_male).values,
                backgroundColor: '#418ad4'
              },
              {
                label: 'Female',
                data: data.slice(:no_dob_female, :age_0_4_female, :age_5_9_female, :age_10_14_female, :age_15_17_female, :age_18_plus_female).values,
                backgroundColor: '#23c6c8'
              },
              {
                label: 'Other',
                data: data.slice(:no_dob_non_binary, :age_0_4_non_binary, :age_5_9_non_binary, :age_10_14_non_binary, :age_15_17_non_binary, :age_18_plus_non_binary).values,
                backgroundColor: '#c72132'
              }
            ]
          }
        }
      }
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
          COUNT(*) FILTER (WHERE #{IS_CHILD}) AS age_child,
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
        FROM clients
        #{joined_province_query}
        WHERE #{client_query} AND #{status_query};
      SQL
  
      ActiveRecord::Base.connection.execute(query).first || {}
    end
  end
end
