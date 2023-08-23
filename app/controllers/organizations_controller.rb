class OrganizationsController < ApplicationController
  inherit_resources
  actions :all

  def index
    index! do |format|
      format.html
      format.csv do
        send_data ExportHandler.call(
          Organization,
          @organizations,
          Organization::EXPORTABLE_COLUMNS
        ), filename: "instances-#{Date.today}.csv"
      end
    end
  end

  def create
    @organization = Organization.new(params.require(:organization).permit(:demo, :full_name, :short_name, :logo, :country, :referral_source_category_name, supported_languages: []))

    if @organization.valid?
      @org = upsert_instance_request("POST")
      org_id = @org&.parsed_response&.dig('organization', 'id')
      if org_id
        @organization = Organization.find(org_id)
        redirect_to resource_url(@organization)
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
     
      if @org && @org.dig("organization", "id")
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

          return redirect_to organizations_path
        end
      else
        redirect_to resource_url(@organization)
      end
    else
      redirect_to organizations_path
    end
  rescue Apartment::TenantNotFound
    redirect_to organizations_path
  end

  protected

  def collection
    params[:q] ||= {}
    params[:q][:s] ||= "created_at desc"
    
    @q = (get_collection_ivar || set_collection_ivar(end_of_association_chain.without_shared.page(params[:page]))
    ).ransack(params[:q])

    @organizations = @q.result(distinct: true)
  end

  private

  def upsert_instance_request(http_verb)
    current_admin_user.generate_token!
    logo = params.dig(:organization, :logo) ? { logo: params.dig(:organization, :logo) } : {}

    attributes = {
      headers: { Authorization: "Token token=#{current_admin_user&.token}" },
      body: {
        full_name: params.dig(:organization, :full_name),
        demo: params.dig(:organization, :demo),
        short_name: @organization.new_record? ? params.dig(:organization, :short_name) : @organization.short_name,
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
