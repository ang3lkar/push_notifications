class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :edit, :update, :destroy]

  # GET /messages
  # GET /messages.json
  def index
    @messages = Message.all
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
  end

  # GET /messages/new
  def new
    @message = Message.new
  end

  # GET /messages/1/edit
  def edit
  end

  # POST /messages
  # POST /messages.json
  def create
    @message = Message.new(message_params)

    respond_to do |format|
      if @message.save
        notification_id = send_message_to_firebase(@message)
        @message.notification_id = notification_id
        @message.save

        format.html { redirect_to @message, notice: 'Message was successfully created.' }
        format.json { render :show, status: :created, location: @message }
      else
        format.html { render :new }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message.destroy
    respond_to do |format|
      format.html { redirect_to messages_url, notice: 'Message was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_message
    @message = Message.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def message_params
    params.require(:message).permit(:title, :text, :key, :value)
  end

  def send_message_to_firebase(message)
    fcm = FCM.new(ENV['FIREBASE_NOTIFICATION_SERVER_KEY'])
    device = 'dP5HYCbWl_E:APA91bE6L6aZ3mW5AGbI8XaJwf62WYNateYRKcEYzNmhOZNE6wIO3b51lQPUbM4OqSrcPABA2-s4kkksiiivxRVCzjFacsw1oFqO6PF_jTT_oYEccQj8x0qtJ5CEYTef6Zs5HMggJB7o'
    registration_ids = device

    response = fcm.send(registration_ids, firebase_options(message_params))

    body = JSON.parse response.with_indifferent_access[:body]
    message_id = body['results'].first['message_id']
    message_id.presence
  end

  def firebase_options(params)
    {
      notification: {
        title: params[:title],
        body: params[:text],
        sound: true,
        color: '#FFFFFF'
      }
    }.merge(data: {
      title: params[:title],
      body: params[:text],
      sound: true,
      color: '#FFFFFF',
      "#{params[:key]}" => params[:value]
    })
  end
end
