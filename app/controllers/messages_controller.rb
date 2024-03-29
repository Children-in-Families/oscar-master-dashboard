class MessagesController < ApplicationController
  def index
    authorize Ahoy::Message

    params[:q] ||= {}
    params[:q][:s] ||= "sent_at desc"
    
    Organization.switch_to(params[:by_tenant]) if params[:by_tenant].present?

    @q = Ahoy::Message.page(params[:page]).ransack(params[:q])
    @messages = @q.result(distinct: true).limit(100)
  end
end
