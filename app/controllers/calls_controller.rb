class CallsController < ApplicationController
  
  # def show
  # end

  # def create
  # end
  
  def update
    call = Call.all.find(params[:id])
    call.update(call_params)
    if (!!call.outcome && !!call.duration && !!call.notes && call.commitment)
      action = Action.all.find(call.action_id)
      action.update(complete: true, date: Time.now)
    end
    render json: call
  end

  def destroy
  end

  private

  def call_params
    params.require(:call).permit(:outcome, :duration, :notes, :commitment, :action_id)
  end
end

