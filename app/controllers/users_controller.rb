class UsersController < ApplicationController
  before_action :check_current_user

  def index
    render json: current_user, serializer: UserSerializer
  end

end
