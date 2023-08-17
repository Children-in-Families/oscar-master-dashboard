class AdminUsersController < ApplicationController
  inherit_resources
  actions :all

  def permitted_params
    params.permit(:admin_user => [:first_name, :last_name, :email, :password, :password_confirmation])
  end
end
