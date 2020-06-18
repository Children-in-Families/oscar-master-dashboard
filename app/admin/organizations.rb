ActiveAdmin.register Organization, as: 'Instance' do
  permit_params :logo, :full_name, :short_name, supported_languages: []

  action_item :monthly_usage_report, only: [:show] do
    link_to 'Monthly Usage Report', monthly_usage_report_admin_instance_path(resource)
  end

  index do
    selectable_column

    column :full_name
    column 'Subdomain', :short_name
    # For debug data
    column 'Number of Clients', :active_client do |orgnanization|
      Apartment::Tenant.switch(orgnanization.short_name) do
        Client.count
      end
    end

    column 'Number of Active Clients', :active_client do |orgnanization|
      Apartment::Tenant.switch(orgnanization.short_name) do
        Client.active_status.count
      end
    end

    column 'Number of accepted clients', :active_client do |orgnanization|
      Apartment::Tenant.switch(orgnanization.short_name) do
        Client.accepted_status.count
      end
    end

    column :display_supported_languages

    actions do |resource|
      link_to 'Monthly Usage Report', monthly_usage_report_admin_instance_path(resource)
    end
  end

  show do
    attributes_table do
      row :full_name
      row :short_name
      row :logo do |instance|
        image_tag instance.logo.url, height: 120
      end

      row 'Number of Active Clients', :active_client do |orgnanization|
        Apartment::Tenant.switch(orgnanization.short_name) do
          Client.active_status.count
        end
      end

      row 'Number of accepted clients', :active_client do |orgnanization|
        Apartment::Tenant.switch(orgnanization.short_name) do
          Client.accepted_status.count
        end
      end

      row :display_supported_languages

      row :created_at
    end
  end

  form do |f|
    f.inputs do
      f.input :full_name
      f.input :short_name
      f.input :logo
      f.input :supported_languages, collection: Organization::SUPPORTED_LANGUAGES.map{ |key, label| [label, key]}, multiple: true, include_blank: false
    end

    f.actions
  end

  member_action :monthly_usage_report, method: :get do
    @page_title = "Usage report for #{resource.full_name} in #{1.month.ago.strftime('%B %Y')}"
    report = MonthlyUsageReport.new(resource)
    @data = report.data
  end

  controller do
    def create
      @resource = Organization.new(params.require(:organization).permit(:full_name, :short_name, :logo, supported_languages: []))

      if @resource.valid?
        @org = create_instance_request

        if @org && @org['id']
          @resource = Organization.find(@org['id'])
          redirect_to resource_url(@resource)
        else
          render :new
        end
      else
        render :new
      end
    end

    private

    def create_instance_request
      # Update token every request
      current_admin_user.generate_token!

      HTTParty.post(
        "#{ENV["OSCAR_HOST"]}/api/v1/organizations",
        headers: { Authorization: "Token token=#{current_admin_user&.token}" },
        body: {
          full_name: params.dig(:organization, :full_name),
          short_name: params.dig(:organization, :short_name),
          logo: params.dig(:organization, :logo),
          supported_languages: params.dig(:organization, :supported_languages)
        }
      )
    end
  end
end
