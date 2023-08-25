class FinancesController < ApplicationController
  def index
    authorize :finance
  end
end
