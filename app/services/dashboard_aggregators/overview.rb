# frozen_string_literal: true

module DashboardAggregators
  class Overview < Base
    def call
      data = organizations.map do |organization|
        Organization.switch_to(organization.short_name)

        case_overview.merge(reaccepting_cases)
          .merge(child_protection)
          .merge(client_risk_assessments)
          .symbolize_keys
      end.each_with_object({}) do |data_per_org, output|
        data_per_org.each do |key, value|
          output[key] ||= 0
          output[key] += value.to_i
        end
      end

      {
        raw_data: data,
        chart_data: {
          case_by_status: {
            labels: ['Active', 'Accepted', 'Exited', 'Referred'],
            datasets: [
              {
                data: [
                  data[:active],
                  data[:accepted],
                  data[:exited],
                  data[:referred]
                ],
                backgroundColor: ['#1ab394', '#23c6c8', '#c72132', '#ed5565'],
                hoverBackgroundColor: ['#1ab394', '#23c6c8', '#c72132', '#ed5565']
              }
            ]
          },
          child_protection: {
            labels: ['Male', 'Female', 'Other'],
            datasets: [
              {
                data: [
                  data[:child_protection_male_count],
                  data[:child_protection_female_count],
                  data[:child_protection_non_binary_count]
                ],
                backgroundColor: ['#1ab394', '#23c6c8', '#c72132'],
                hoverBackgroundColor: ['#1ab394', '#23c6c8', '#c72132']
              }
            ]
          },
          risk_assessments: {
            labels: ['High', 'Medium', 'Low', 'No Action'],
            datasets: [
              {
                data: [
                  data[:risk_high],
                  data[:risk_medium],
                  data[:risk_low],
                  data[:risk_no_action]
                ],
                backgroundColor: ['#1ab394', '#23c6c8', '#c72132', '#ed5565'],
                hoverBackgroundColor: ['#1ab394', '#23c6c8', '#c72132', '#ed5565']
              }
            ]
          }
        }
      }
    end

    private

    def case_overview
      query = <<-SQL.squish
        SELECT
          COUNT(*) AS case_overview_total,
          COUNT(*) FILTER (WHERE status = 'Exited') AS exited,
          COUNT(*) FILTER (WHERE status = 'Accepted') AS accepted,
          COUNT(*) FILTER (WHERE status = 'Active') AS active,
          COUNT(*) FILTER (WHERE status = 'Referred') AS referred,
          COUNT(*) FILTER (WHERE status = 'Exited') AS case_overview_closed,
          COUNT(*) FILTER (WHERE #{IS_ACCEPTED_OR_ACTIVE}) AS case_overview_opening
        FROM clients
        #{disability_query}
        #{joined_province_query}
        WHERE #{client_query};
      SQL

      ActiveRecord::Base.connection.execute(query).first || {}
    end

    def reaccepting_cases
      query = <<-SQL.squish
        SELECT COUNT(*) as reaccepting_cases
        FROM clients
        JOIN enter_ngos ON enter_ngos.client_id = clients.id
        #{disability_query}
        #{joined_province_query}
        WHERE #{client_query}
        GROUP BY clients.id
        HAVING COUNT(enter_ngos.client_id) > 1;
      SQL

      ActiveRecord::Base.connection.execute(query).first || {}
    end

    def child_protection
      service_ids = Service.where(name: ['Family Based Care', 'Drug/Alcohol', 'Anti-Trafficking']).ids
      service_ids += Service.where(parent_id: service_ids).ids

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
        #{disability_query}
        #{joined_province_query}
        WHERE services.id IN (#{service_ids.join(', ')}) AND #{IS_CHILD} AND #{client_query};
      SQL
  
      ActiveRecord::Base.connection.execute(query).first || {}
    end

    def client_risk_assessments
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
          COUNT(*) FILTER (WHERE latest_risk_levels.level_of_risk = 'low') AS risk_low,
          COUNT(*) FILTER (WHERE latest_risk_levels.level_of_risk = 'medium') AS risk_medium,
          COUNT(*) FILTER (WHERE latest_risk_levels.level_of_risk = 'high') AS risk_high,
          COUNT(*) FILTER (WHERE latest_risk_levels.level_of_risk = 'no action') AS risk_no_action
        FROM latest_risk_levels
        JOIN clients ON clients.id = latest_risk_levels.client_id
        #{disability_query}
        #{joined_province_query}
        WHERE #{client_query};
      SQL
  
      ActiveRecord::Base.connection.execute(query).first || {}
    end
  end
end
