# frozen_string_literal: true

module DashboardAggregators
  class SyncOverview < Base
    def call
      data = organizations.map do |organization|
        Organization.switch_to(organization.short_name)
        cases_synced_to_primero
          .merge(cases_referred_primero)
          .merge(rejected_cases_referred_primero)
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
          synced_case_by_gender: {
            labels: ['Adule', 'Child'],
            datasets: [
              {
                label: 'Male',
                data: data.slice(:adult_male_cases_synced, :child_male_cases_synced).values,
                backgroundColor: '#418ad4'
              },
              {
                label: 'Female',
                data: data.slice(:adult_female_cases_synced, :child_female_cases_synced).values,
                backgroundColor: '#23c6c8'
              },
              {
                label: 'Other',
                data: data.slice(:adult_non_binary_cases_synced, :child_non_binary_cases_synced).values,
                backgroundColor: '#c72132'
              }
            ]
          },
          case_referral_by_gender: {
            labels: ['Referred to Primero', 'Referred from Primero'],
            datasets: [
              {
                label: 'Male',
                data: data.slice(:male_cases_referred_to_primero, :male_cases_referred_from_primero).values,
                backgroundColor: '#418ad4'
              },
              {
                label: 'Female',
                data: data.slice(:female_cases_referred_to_primero, :female_cases_referred_from_primero).values,
                backgroundColor: '#23c6c8'
              },
              {
                label: 'Other',
                data: data.slice(:non_binary_cases_referred_to_primero, :non_binary_cases_referred_from_primero).values,
                backgroundColor: '#c72132'
              }
            ]
          },
          case_referral_by_status: {
            labels: ['Pending', 'Accepted', 'Rejected'],
            datasets: [
              {
                data: [
                  data[:pending_cases_referred_to_primero],
                  data[:accepted_cases_referred_to_primero],
                  data[:rejected_cases_referred_primero]
                ],
                backgroundColor: ['#418ad4', '#23c6c8', '#c72132'],
                hoverBackgroundColor: ['#418ad4', '#23c6c8', '#c72132']
              }
            ]
          }
        }
      }
    end

    private

    def cases_synced_to_primero
      query = <<-SQL.squish
        SELECT
          COUNT(*) AS total_cases_synced,
          COUNT(*) FILTER (WHERE #{IS_CHILD}) AS child_cases_synced,
          COUNT(*) FILTER (WHERE #{IS_CHILD} AND #{IS_MALE}) AS child_male_cases_synced,
          COUNT(*) FILTER (WHERE #{IS_CHILD} AND #{IS_FEMALE}) AS child_female_cases_synced,
          COUNT(*) FILTER (WHERE #{IS_CHILD} AND #{IS_NON_BINARY}) AS child_non_binary_cases_synced,
          COUNT(*) FILTER (WHERE #{IS_AGE_18PLUS}) AS adult_cases_synced,
          COUNT(*) FILTER (WHERE #{IS_AGE_18PLUS} AND #{IS_MALE}) AS adult_male_cases_synced,
          COUNT(*) FILTER (WHERE #{IS_AGE_18PLUS} AND #{IS_FEMALE}) AS adult_female_cases_synced,
          COUNT(*) FILTER (WHERE #{IS_AGE_18PLUS} AND #{IS_NON_BINARY}) AS adult_non_binary_cases_synced
        FROM clients
        WHERE synced_date IS NOT NULL;
      SQL

      ActiveRecord::Base.connection.execute(query).first || {}
    end

    def cases_referred_primero
      query = <<-SQL.squish
        SELECT
          COUNT(DISTINCT clients.id) FILTER (WHERE #{REFERRED_TO_PRIMERO}) AS total_cases_referred_to_primero,
          COUNT(DISTINCT clients.id) FILTER (WHERE #{REFERRED_TO_PRIMERO} AND #{IS_MALE}) AS male_cases_referred_to_primero,
          COUNT(DISTINCT clients.id) FILTER (WHERE #{REFERRED_TO_PRIMERO} AND #{IS_FEMALE}) AS female_cases_referred_to_primero,
          COUNT(DISTINCT clients.id) FILTER (WHERE #{REFERRED_TO_PRIMERO} AND #{IS_NON_BINARY}) AS non_binary_cases_referred_to_primero,
          COUNT(DISTINCT clients.id) FILTER (WHERE #{REFERRED_TO_PRIMERO} AND referrals.referral_status = 'Referred') AS pending_cases_referred_to_primero,
          COUNT(DISTINCT clients.id) FILTER (WHERE #{REFERRED_TO_PRIMERO} AND referrals.referral_status = 'Accepted') AS accepted_cases_referred_to_primero,
          COUNT(DISTINCT clients.id) FILTER (WHERE #{REFERRED_FROM_PRIMERO}) AS total_cases_referred_from_primero,
          COUNT(DISTINCT clients.id) FILTER (WHERE #{REFERRED_FROM_PRIMERO} AND #{IS_MALE}) AS male_cases_referred_from_primero,
          COUNT(DISTINCT clients.id) FILTER (WHERE #{REFERRED_FROM_PRIMERO} AND #{IS_FEMALE}) AS female_cases_referred_from_primero,
          COUNT(DISTINCT clients.id) FILTER (WHERE #{REFERRED_FROM_PRIMERO} AND #{IS_NON_BINARY}) AS non_binary_cases_referred_from_primero
        FROM clients
        JOIN referrals ON clients.id = referrals.client_id
        WHERE #{REFERRED_TO_PRIMERO} OR #{REFERRED_FROM_PRIMERO};
      SQL

      ActiveRecord::Base.connection.execute(query).first || {}
    end

    def rejected_cases_referred_primero
      query = <<-SQL.squish
        SELECT
          COUNT(DISTINCT clients.id) AS rejected_cases_referred_primero
        FROM clients
        JOIN referrals ON clients.id = referrals.client_id AND #{REFERRED_TO_PRIMERO}
        JOIN exit_ngos ON clients.id = exit_ngos.client_id AND exit_ngos.exit_circumstance = 'Rejected Referral';
      SQL

      ActiveRecord::Base.connection.execute(query).first || {}
    end
  end
end
