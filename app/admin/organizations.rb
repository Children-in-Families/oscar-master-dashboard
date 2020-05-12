ActiveAdmin.register Organization, as: 'Instance' do
  index do
    selectable_column

    column :short_name
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
