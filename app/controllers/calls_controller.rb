class CallsController < ApplicationController
  
  # def show
  # end

  # def create
  # end
  
  def update
    call = Call.all.find(params[:id])
    call.update(call_params)
    action = Action.all.find(call.action_id)
    
    if (!call.outcome || call.outcome == "" || !call.duration || !call.notes || call.notes == "" || !call.commitment || call.commitment == "")
      action.update(complete: false, date: nil)
    else
      action.update(complete: true, date: Time.now)
    end
    render json: call
  end

  # def destroy
  # end

  private

  def call_params
    params.require(:call).permit(:outcome, :duration, :notes, :commitment, :action_id)
  end
end

