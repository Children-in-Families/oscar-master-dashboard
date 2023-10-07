class ReleaseNotesController < ApplicationController
  inherit_resources
  actions :all, except: [:destroy]

  before_action :authorize_resource!, except: :publish

  def permitted_params
    params.permit(:release_note => [:content])
  end

  def create
    create! do |format|
      format.html do
        resource.update(created_by_id: current_admin_user.id)
        redirect_to release_notes_path, notice: 'Congration, this release note has been successfully created!'
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
