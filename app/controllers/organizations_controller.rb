class OrganizationsController < ApplicationController
  inherit_resources
  actions :all

  before_action :authorize_resource!

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
    @organization = Organization.new(params.require(:organization).permit(:demo, :full_name, :short_name, :logo, :country, :referral_source_category_name, :parent_id, supported_languages: []))

    if @organization.valid?
      @org = upsert_instance_request("POST")
      Rails.logger.info "========================== @org =========================="
      Rails.logger.info @org

      org_id = @org&.parsed_response&.dig('organization', 'id') if @org&.parsed_response.is_a?(Hash)

      if org_id
        @organization = Organization.find(org_id)
        redirect_to resource_url(@organization)
      else
        flash[:alert] = @org&.parsed_response
        render :new
      end
    else
      render :new
    end
  end

  def update
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
    if @organization.deleted_at?
      begin
        Organization.transaction do
          GlobalIdentityOrganization.where(organization_id: @organization.id).delete_all

          @organization.destroy_fully!
          OrganizationMailer.notify_organization_deleted(@organization.full_name, current_admin_user).deliver_now
        end

        Apartment::Tenant.drop(@organization.short_name)
      rescue Apartment::TenantNotFound => e
        # Ignore this error as it has issue when creating new instance
        Rails.logger.info "========================== e =========================="
      end

      redirect_to collection_url(scope: "archived"), notice: 'Instance was successfully deleted.'
    else
      @organization.destroy!
      OrganizationMailer.notify_organization_archived(@organization, current_admin_user).deliver_now

      redirect_to collection_url, notice: 'Instance was successfully archived.'
    end
  end

  def restore
    @organization.recover!
    redirect_to collection_url, notice: 'Instance was successfully restored.'
  end

  protected

  def collection
    params[:q] ||= {}
    params[:q][:s] ||= "created_at desc"

    list = get_collection_ivar || set_collection_ivar(end_of_association_chain.without_shared.page(params[:page]))
    list = list.archived if params[:scope] == "archived"

    @q = list.ransack(params[:q])
    @organizations = @q.result(distinct: true)
  end

  private

  def upsert_instance_request(http_verb)
    current_admin_user.generate_token!
    logo = params.dig(:organization, :logo) ? { logo: params.dig(:organization, :logo) } : {}

    attributes = {
      headers: { Authorization: "Token token=#{current_admin_user&.token}" },
      body: params.require(:organization).permit(:demo, :full_name, :short_name, :logo, :country, :referral_source_category_name, :parent_id, supported_languages: []).to_h
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

  def authorize_resource!
    if params[:id]
      @organization = Organization.with_deleted.find(params[:id])
      authorize @organization
    else
      authorize Organization
    end
  end
end
