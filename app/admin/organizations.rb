ActiveAdmin.register Organization, as: 'Instance' do
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

    actions
  end
end
