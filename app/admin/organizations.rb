ActiveAdmin.register Organization, as: 'Instance' do
  permit_params :logo, :full_name, :short_name, supported_languages: []

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

  show do
    attributes_table do
      row :full_name
      row :short_name
      row :logo do |instance|
        image_tag instance.logo.url
      end

      row :created_at
    end
  end

  form do |f|
    f.inputs do
      f.input :full_name
      f.input :short_name
      f.input :logo
    end

    f.actions
  end

  controller do
    def create
      @resource = Organization.new(params.require(:organization).permit(:full_name, :short_name, :logo))

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
  end
end
