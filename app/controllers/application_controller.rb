class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :authenticate_admin_user!
  after_action :verify_authorized, unless: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def after_sign_in_path_for(resource)
    root_path_by_role(resource)
  end

  private
  
  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to root_path_by_role
  end
  
  def pundit_user
    current_admin_user
  end

  def root_path_by_role(user = nil)
    user ||= current_admin_user

    if user.finance?
      billable_reports_path
    else
      root_path
    end
  end
end
