class DashboardsController < ApplicationController
  def show
    authorize :dashboard
    Organization.switch_to('cif')

    @q = Client.with_deleted.reportable.ransack(params[:q])
    @report_data = {
      openning_case: @q.result.accepted_or_active.count,
      closed_case: @q.result.exited.count,
      risk_level: Assessment.client_risk_assessments.joins(:client).group(:level_of_risk).count
    }
  end
end
