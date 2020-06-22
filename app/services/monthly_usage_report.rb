class MonthlyUsageReport
  attr_reader :end_of_month, :beginning_of_month

  def initialize
    @beginning_of_month = 1.month.ago.beginning_of_month
    @end_of_month       = 1.month.ago.end_of_month
  end

  def aggregate_data_without_dev
    output = {
      user_count: 0,
      user_added_count: 0,
      user_deleted_count: 0,
      login_per_month: 0,
      client_count: 0,
      client_added_count: 0,
      client_deleted_count: 0,
      tranferred_client_count: 0
    }

    Organization.where.not(short_name: %w(shared demo)).find_each do |organization|
      data_per_org = data_per_org(organization)

      output[:user_count] += data_per_org[:user_count]
      output[:user_added_count] += data_per_org[:user_added_count]
      output[:user_deleted_count] += data_per_org[:user_deleted_count]
      output[:login_per_month] += data_per_org[:login_per_month]
      output[:client_count] += data_per_org[:client_count]
      output[:client_added_count] += data_per_org[:client_added_count]
      output[:client_deleted_count] += data_per_org[:client_deleted_count]
      output[:tranferred_client_count] += data_per_org[:tranferred_client_count]
    end

    output
  end

  def data_per_org(organization)
    Organization.switch_to(organization.short_name)

    previous_month_users = PaperTrail::Version.where(item_type: 'User', created_at: beginning_of_month..end_of_month)
    previous_month_clients = PaperTrail::Version.where(item_type: 'Client', created_at: beginning_of_month..end_of_month)
    tranferred_clients = PaperTrail::Version.where(item_type: 'Referral', event: 'create', created_at: beginning_of_month..end_of_month)

    {
      ngo_name: organization.full_name,
      ngo_on_board: organization.created_at.strftime("%d %B %Y"),
      fcf: organization.fcf_ngo? ? 'Yes' : 'No',
      ngo_country: Setting.first&.country_name&.titleize,
      user_count: User.non_devs.count,
      user_added_count: previous_month_users.where(event: 'create').count,
      user_deleted_count: previous_month_users.where(event: 'destroy').count,
      login_per_month: Visit.excludes_non_devs.total_logins(beginning_of_month, end_of_month).count,
      client_count: Client.count,
      client_added_count: previous_month_clients.where(event: 'create').count,
      client_deleted_count: previous_month_clients.where(event: 'destroy').count,
      tranferred_client_count: tranferred_clients.map{ |a| a.changeset.dig(:slug) && a.changeset[:slug][1] }.compact.uniq.count
    }
  end
end
