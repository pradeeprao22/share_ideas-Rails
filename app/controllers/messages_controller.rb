class MessagesController < ApplicationController
  include ActionController::Cookies
  before_action :set_cookie, only: [:index]

  before_action do
    @conversation = Conversation.find_by_id(params[:conversation_id])
  end

  def index
    @conversations = Conversation.all
    @messages = @conversation.messages
    @message = @conversation.messages.new
    @user_id = @conversation.recipient_id
  end

  def messages_index
    @messages = @conversation.messages
    render json: @messages
  end

  def new
    @message = @conversation.messages.new
  end

  def create
    @message = @conversation.messages.new(conversation_id: params[:conversation_id],
                                          user_id: params[:message][:user_id], body: params[:message][:body])
    return unless @message.save

    # message sender
    @user_send = @message.user.id.to_i
    @verified_user = cookies[:verified_user].to_i
    if @conversation.sender.id == @verified_user.to_i
      @user_rec = @conversation.recipient.id.to_i
    elsif @conversation.recipient.id == @verified_user.to_i
      @user_rec = @conversation.sender.id.to_i
    else
      flash[:notice] = 'Some error'
    end
    # message sent current user
    # @message_sent_user = @conversation.recipient.id

    ActionCable.server.broadcast('message', {
                                   message: @message.body,
                                   current_user: @user_rec,
                                   # user_rec: @user_rec,
                                   verified_user: @verified_user,
                                   created: @message.created_at.strftime("%b %d, %Y %I:%M %p")
                                 })
    head :ok
    # redirect_to conversation_messages_path(@conversation)
  end

  private

  def set_cookie
    cookies[:verified_user] = current_user.id
    verified_user = cookies[:verified_user]
  end

  def message_params
    params.permit(:body, :user_id, :conversation_id)
  end
end
