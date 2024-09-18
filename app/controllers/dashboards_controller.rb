class DashboardsController < ApplicationController
  def show
    authorize :dashboard
    Organization.switch_to('cif')

    @q = Client.with_deleted.reportable.ransack(params[:q])
    @report = DashboardAggregator.new.call
  end
end
