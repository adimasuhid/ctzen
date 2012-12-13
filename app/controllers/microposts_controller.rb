class MicropostsController < ApplicationController
  before_filter :signed_in_user, only: [:create,:destroy]
  before_filter :correct_user, only: :destroy
  before_filter :process_direct_messages, :only => :create


  def index
  end


  def create
    @micropost = current_user.microposts.build(params[:micropost])
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    redirect_to root_url
  end
  
  
  private
  
    def process_direct_messages
        @micropost = current_user.microposts.build(params[:micropost])
        if @micropost.direct_message_format?
         direct_message = DirectMessage.new(@micropost.to_direct_message_hash)
         redirect_to root_path if direct_message.save
        end
     end

    def correct_user
      @micropost = current_user.microposts.find_by_id(params[:id])
      redirect_to root_url if @micropost.nil?
    end

   
end
