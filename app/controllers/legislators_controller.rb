class LegislatorsController < ApplicationController
  def index
    legislators = Legislator.all
    render json: legislators, each_serializer: LegislatorSerializer    
  end
end
