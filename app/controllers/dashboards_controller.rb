class DashboardsController < ApplicationController
  def show
    authorize :dashboard
    Organization.switch_to('cif')

    @q = Client.with_deleted.reportable.ransack(params[:q])
    @report_data = Client.client_risk_assessments_aggregates.merge(Client.client_based_aggregates).merge(Client.child_protection_aggregates)
  end
end
