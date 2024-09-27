# frozen_string_literal: true

class DashboardFilter
  include ActiveModel::Model

  attr_accessor :organization_ids
  attr_accessor :organization_integrated
  attr_accessor :organization_created_at_gteq
  attr_accessor :organization_created_at_lteq
  attr_accessor :country
  attr_accessor :international

  attr_accessor :has_disability
  attr_accessor :created_at_lteq
  attr_accessor :created_at_gteq
  attr_accessor :status
  attr_accessor :initial_referral_date_lteq
  attr_accessor :initial_referral_date_gteq
  attr_accessor :province_id
  attr_accessor :synced_date_lteq
  attr_accessor :synced_date_gteq
  attr_accessor :referral_date_gteq
  attr_accessor :referral_date_lteq

  def organizations
    query = "1 = 1"
    query += " AND organizations.created_at >= '#{organization_created_at_gteq}'" if organization_created_at_gteq.present?
    query += " AND organizations.created_at <= '#{organization_created_at_lteq}'" if organization_created_at_lteq.present?
    query += " AND organizations.integrated = #{organization_integrated}" if organization_integrated.present?
    query += " AND organizations.id IN (#{organization_ids.join(',')})" if organization_ids.present?
    query += " AND organizations.country IN (#{country.map { |c| "'#{c}'" }.join(',')})" if country.present?

    if international == 'true'
      query += " AND organizations.country != 'cambodia'"
    elsif international == 'false'
      query += " AND organizations.country = 'cambodia'"
    end

    Organization.non_demo.active.where(query)
  end

  def client_query
    query = "1 = 1"

    query += " AND clients.created_at >= '#{created_at_gteq}'" if created_at_gteq.present?
    query += " AND clients.created_at <= '#{created_at_lteq}'" if created_at_lteq.present?
    query += " AND clients.initial_referral_date >= '#{initial_referral_date_gteq}'" if initial_referral_date_gteq.present?
    query += " AND clients.initial_referral_date <= '#{initial_referral_date_lteq}'" if initial_referral_date_lteq.present?
    query += " AND clients.synced_date >= '#{synced_date_gteq}'" if synced_date_gteq.present?
    query += " AND clients.synced_date <= '#{synced_date_lteq}'" if synced_date_lteq.present?

    query
  end

  def referral_query
    query = "1 = 1"
    query += " AND referrals.date_of_referral >= '#{referral_date_gteq}'" if referral_date_gteq.present?
    query += " AND referrals.date_of_referral <= '#{referral_date_lteq}'" if referral_date_lteq.present?

    query
  end

  def disability_query
    "JOIN risk_assessments ON clients.id = risk_assessments.client_id AND risk_assessments.has_disability = true" if disability?
  end

  def disability?
    has_disability == true || has_disability == 'true' || has_disability == '1'
  end

  def status_query
    query = "1 = 1"

    query += " AND clients.status IN (#{status.map { |c| "'#{c}'" }.join(',')})" if status.present?

    query
  end
end
