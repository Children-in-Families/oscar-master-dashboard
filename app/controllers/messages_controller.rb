class MessagesController < ApplicationController
  def index
    authorize Ahoy::Message
    
    params[:q] ||= {}
    params[:q][:s] ||= "created_at desc"

    @q = Ahoy::Message.page(params[:page]).ransack(params[:q])
    @messages = @q.result(distinct: true)
  end
end
