ActiveAdmin.register Organization, as: "Instance" do
  menu priority: 2

  actions :all

  config.remove_action_item(:destroy)
  config.clear_batch_actions!

  before_action :update_client_data, only: [:show, :index]

  permit_params :logo, :demo, :full_name, :short_name, supported_languages: []

  scope :all

  scope :non_demo, default: true, group: :demo
  scope :demo, group: :demo

  scope "English", :en, group: :language
  scope "Khmer", :km, group: :language
  scope "Burmese", :my, group: :language

  filter :full_name
  filter :short_name, label: "Subdomain"
  filter :country
  filter :clients_count, label: "Number of Clients"
  filter :active_client, label: "Number of Active Clients"
  filter :accepted_client, label: "Number of accepted clients"

  filter :created_at, label: "NGO Onboard Date"

  action_item :monthly_usage_report, only: [:show] do
    link_to "Monthly Usage Report", monthly_usage_report_admin_instance_path(resource)
  end

  action_item :delete, only: [:show] do
    if resource.deletable?
      link_to "Delete Instance", {action: :destroy}, method: :delete, data: {confirm: "This operation cannot be undo, are you sure you want to delete this instance?"}
    end
  end

  index do
    selectable_column

    column :full_name
    column "Demo?", :demo_status
    column "Subdomain", :short_name
    column :country do |instance|
      instance.country&.titleize
    end

    column "Number of Clients", :clients_count
    column "Number of Active Clients", :active_client
    column "Number of accepted clients", :accepted_client

    column :display_supported_languages
    column "NGO Onboard Date", :created_at

    actions defaults: false do |resource|
      link_to "View", admin_instance_path(resource)
    end

    actions defaults: false do |resource|
      link_to "Edit", edit_admin_instance_path(resource)
    end

    actions defaults: false do |resource|
      link_to "Delete", admin_instance_path(resource), method: :delete, data: {confirm: "This operation cannot be undo, are you sure you want to delete this instance?"} if resource.deletable?
    end

    actions defaults: false do |resource|
      link_to "Monthly Usage Report", monthly_usage_report_admin_instance_path(resource)
    end
  end

  show do
    attributes_table do
      row :full_name
      row :short_name, "Subdomain"
      row :referral_source_category_name
      row :country
      row :logo do |instance|
        image_tag instance.logo.url, height: 120
      end

      row "Demo?" do |instance|
        instance.demo_status
      end

      row "Number of Clients" do |instance|
        instance.clients_count
      end

      row "Number of Active Clients" do |instance|
        instance.active_client
      end

      row "Number of accepted clients" do |instance|
        instance.accepted_client
      end

      row "NGO Onboard Date" do |instance|
        instance.created_at
      end

      row :display_supported_languages
    end
  end

  form do |f|
    f.inputs do
      f.input :full_name
      f.input :short_name, label: "Subdomain"
      f.input :referral_source_category_name, as: :select, collection: ReferralSource.parent_categories.where.not(name_en: [nil, '']).pluck(:name_en, :name_en), label: "Referral Source Category", required: true
      f.input :demo, label: "Demo?"
      f.input :logo
      f.input :country, as: :select, collection: [Organization::SUPPORTED_COUNTRY.map(&:titleize), Organization::SUPPORTED_COUNTRY].transpose, selected: f.object.country
      f.input :supported_languages, collection: Organization::SUPPORTED_LANGUAGES.map { |key, label| [label, key] }, multiple: true, include_blank: false
    end

    f.actions
  end

  member_action :monthly_usage_report, method: :get do
    @month = params.dig(:report, :month) || Date.current.month
    @year = params.dig(:report, :year) || Date.current.year

    beginning_of_month = Date.new(@year.to_i, @month.to_i, 1)
    end_of_month = beginning_of_month.end_of_month

    @page_title = "Usage report for #{resource.full_name} for #{beginning_of_month.strftime("%B %Y")}"
    report = MonthlyUsageReport.new(beginning_of_month, end_of_month)

    @data = report.data_per_org(resource)
  end

  controller do
    def create
      @resource = Organization.new(params.require(:organization).permit(:demo, :full_name, :short_name, :logo, :country, :referral_source_category_name, supported_languages: []))

      if @resource.valid?
        @org = upsert_instance_request("POST")
        org_id = @org&.parsed_response&.dig('organization', 'id')
        if org_id
          @resource = Organization.find(org_id)
          redirect_to resource_url(@resource)
        else
          render :new
        end
      else
        render :new
      end
    end

    def update
      @organization = Organization.find(params[:id])
      if @organization
        @org = upsert_instance_request("PUT")
        if @org && @org["id"]
          redirect_to resource_url(@organization)
        else
          render :edit
        end
      else
        render :edit
      end
    end

    def destroy
      @organization = Organization.find(params[:id])
      if @organization
        response = destroy_instance_request
        if response.success?
          destroy! do
            Apartment::Tenant.drop(resource.short_name)

            return redirect_to admin_instances_path
          end
        else
          redirect_to resource_url(@organization)
        end
      else
        redirect_to admin_instances_path
      end
    end

    private

    def update_client_data
      Organization.update_client_data
    end

    def upsert_instance_request(http_verb)
      # Update token every request
      current_admin_user.generate_token!
      logo = params.dig(:organization, :logo) ? { logo: params.dig(:organization, :logo) } : {}
      attributes = {
        headers: { Authorization: "Token token=#{current_admin_user&.token}" },
        body: {
          full_name: params.dig(:organization, :full_name),
          demo: params.dig(:organization, :demo),
          short_name: params.dig(:organization, :short_name),
          country: params.dig(:organization, :country),
          supported_languages: params.dig(:organization, :supported_languages),
          referral_source_category_name: params.dig(:organization, :referral_source_category_name),
          **logo
        }
      }

      if http_verb == "POST"
        Organization.post(
          "#{ENV["OSCAR_HOST"]}/api/v1/organizations",
          attributes
        )
      else
        Organization.put(
          "#{ENV["OSCAR_HOST"]}/api/v1/organizations/#{@organization.id}",
          attributes
        )
      end
    end

    def destroy_instance_request
      Organization.delete(
        "#{ENV["OSCAR_HOST"]}/api/v1/organizations/#{@organization.id}", {
          headers: {Authorization: "Token token=#{current_admin_user&.token}"}
        }
      )
    end
  end
end
