class ReleaseNotesController < ApplicationController
  inherit_resources
  actions :all, except: [:destroy, :show]

  before_action :authorize_resource!, except: :publish

  def permitted_params
    params.permit(:release_note => [:content])
  end

  def create
    create! do |format|
      format.html do
        resource.update(created_by_id: current_admin_user.id)
        upload_attachments

        redirect_to release_notes_path, notice: 'Congration, this release note has been successfully created!'
      end
    end
  end

  def update
    update! do |format|
      format.html do
        upload_attachments

        redirect_to release_notes_path, notice: 'Congration, this release note has been successfully updated!'
      end
    end
  end

  def publish
    resource = ReleaseNote.find(params[:id])
    authorize resource

    resource.update(published_at: Time.current, published_by_id: current_admin_user.id, published: true)
    redirect_to release_notes_path, notice: 'Congration, this release note has been successfully published!'
  end

  protected

  def upload_attachments
    attachments = params.dig(:release_note, :attachments)
    
    if attachments.present?
      current_admin_user.generate_token!
      attributes = {
        headers: { Authorization: "Token token=#{current_admin_user.token}" },
        body: {
          attachments: attachments
        }
      }

      HTTParty.put("#{ENV["OSCAR_HOST"]}/api/v1/release_notes/#{resource.id}/upload_attachments", attributes)
    end
  end

  def collection
    params[:q] ||= {}
    params[:q][:s] ||= "created_at desc"

    list = get_collection_ivar || set_collection_ivar(end_of_association_chain.page(params[:page]))

    @q = list.ransack(params[:q])
    @release_notes = @q.result
  end

  private

  def authorize_resource!
    if params[:id]
      authorize resource
    else
      authorize ReleaseNote
    end
  end
end
