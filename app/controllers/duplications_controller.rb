class DuplicationsController < ApplicationController
  def index
    authorize :duplication
  end
end
