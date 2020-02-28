class CallListsController < ApplicationController
  
  def show
  end

  def create 
    # What's wrong with call_list_params?
    campaign_id = call_list_params[:campaign_id]
    call_list_name = call_list_params[:call_list_name]
    current_user_id = call_list_params[:current_user_id]
    legislator_ids = call_list_params[:legislator_ids]

    # create 1 Call list
    new_call_list = CallList.create(campaign_id: campaign_id, name: call_list_name)

    # for each legislator selected (7)...
    legislator_ids.each do |legislator_id|
      # create action with user_id and campaign_id. 
      # hardcoding type as call list. 
      new_action = Action.create(user_id: current_user_id, campaign_id: campaign_id, legislator_id: legislator_id )
      
      # # create legislator action. one for each action id and one for each legislator id
      # LegislatorAction.create(legislator_id: legislator_id, action_id: new_action.id)

      # create call. one for each action id. Eachwith call_list_id
      Call.create(action_id: new_action.id, call_list_id: new_call_list.id)
    end
  
    render json: new_call_list, serializer: CallListSerializer

  end

  def update
  end

  def destroy
  end

  private

  def call_list_params
    params.require(:call_list).permit(:campaign_id, :call_list_name, :current_user_id, legislator_ids: [])
  end
end

