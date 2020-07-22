class AuthController < ApplicationController

  def login
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      token = encode_token(user.id)
      render json: {user: user, token: token}
    else
      render json: {errors: "Invalid email and password"}
    end
  end

  def auto_login
    if logged_in?      
      token = encode_token(session_user.id)
      render json: {user: session_user, token: token}
    else 
      render json: {errors: "Invalid token"}
    end
  end

  def logout
    
  end

end

