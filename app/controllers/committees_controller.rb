class CommitteesController < ApplicationController
  def index
    committees = Committee.all
    render json: committees, each_serializer: CommitteeSerializer    
  end
end
