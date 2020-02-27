class CampaignsController < ApplicationController
 
  def index
    byebug
    campaigns = session_user.campaigns
    render json: campaigns
  end

  def create
  end

  def update
  end

  def destroy
  end

end
