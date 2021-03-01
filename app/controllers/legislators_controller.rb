class LegislatorsController < ApplicationController
  before_action :check_current_user
  
  def index
    legislators = Legislator.all
    render json: legislators, each_serializer: LegislatorSerializer    
  end
end
