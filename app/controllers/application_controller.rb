class ApplicationController < ActionController::Base
  before_action :authenticate_admin_user!

  before_action :fix_date_params

  private

  def fix_date_params
    return unless params[:q]

    params[:q].each do |key, value|
      if key.ends_with?("_lteq") || key.ends_with?("_lt")
        params[:q][key] = Date.parse(value).end_of_day if value.present?
      end
    end
  end
end
