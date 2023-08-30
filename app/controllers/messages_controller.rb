class MessagesController < ApplicationController
  def index
    authorize Ahoy::Message

    params[:q] ||= {}
    params[:q][:s] ||= "created_at desc"

    if params[:by_tenant]
      Apartment::Tenant.switch(params[:by_tenant]) do
        @q = Ahoy::Message.page(params[:page]).ransack(params[:q])
        @messages = @q.result(distinct: true)
      end
    else
      @q = Ahoy::Message.ransack(params[:q])
      @messages = @q.result
    end
  end
end
