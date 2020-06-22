class MonthlyUsageReport
  attr_reader :end_of_month, :beginning_of_month, :organization

  def initialize(organization = nil)
    @organization = organization
    @beginning_of_month = 1.month.ago.beginning_of_month
    @end_of_month       = 1.month.ago.end_of_month
  end

  def data
    Organization.switch_to(organization.short_name) if @organization

    previous_month_users = PaperTrail::Version.where(item_type: 'User', created_at: beginning_of_month..end_of_month)
    previous_month_clients = PaperTrail::Version.where(item_type: 'Client', created_at: beginning_of_month..end_of_month)
    tranferred_clients = PaperTrail::Version.where(item_type: 'Referral', event: 'create', created_at: beginning_of_month..end_of_month)

    output = {
      user_count: User.non_devs.count,
      user_added_count: previous_month_users.where(event: 'create').count,
      user_deleted_count: previous_month_users.where(event: 'destroy').count,
      login_per_month: Visit.excludes_non_devs.total_logins(beginning_of_month, end_of_month).count,
      client_count: Client.count,
      client_added_count: previous_month_clients.where(event: 'create').count,
      client_deleted_count: previous_month_clients.where(event: 'destroy').count,
      tranferred_client_count: tranferred_clients.map{ |a| a.changeset.dig(:slug) && a.changeset[:slug][1] }.compact.uniq.count
    }

    if @organization
      output.merge(
        ngo_name: organization.full_name,
        ngo_on_board: organization.created_at.strftime("%d %B %Y"),
        fcf: organization.fcf_ngo? ? 'Yes' : 'No',
        ngo_country: Setting.first&.country_name&.titleize,
      )
    end

    output
  end
end
