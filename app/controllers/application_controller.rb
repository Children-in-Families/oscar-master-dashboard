class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :authenticate_admin_user!
  after_action :verify_authorized, unless: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end

  def pundit_user
    current_admin_user
  end
end
