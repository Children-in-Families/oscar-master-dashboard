class DashboardsController < ApplicationController
  def show
    authorize :dashboard
  end
end
