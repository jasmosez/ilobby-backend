class CampaignsController < ApplicationController
 
  # def index
  #   byebug
  #   campaigns = session_user.campaigns
  #   render json: campaigns
  # end

  def create
    campaign = Campaign.create(campaign_params)
    render json: campaign
  end
  
  def update
    campaign = Campaign.find(params[:id])
    campaign.update(campaign_params)
    render json: campaign
  end
  
  # def destroy
  #   byebug
  #   campaign = Campaign.find(params[:id])
  #   campaign.destroy
  #   render json: campaign
  # end

  private

  def campaign_params
    params.require(:campaign).permit(:user_id, :name)
  end

end
