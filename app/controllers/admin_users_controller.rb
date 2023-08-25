class AdminUsersController < ApplicationController
  inherit_resources
  actions :all

  before_action :authorize_resource!

  def permitted_params
    params.permit(:admin_user => [:first_name, :last_name, :email, :password, :password_confirmation, :role])
  end

  private

  def authorize_resource!
    if params[:id]
      authorize resource
    else
      authorize AdminUser
    end
  end
end
