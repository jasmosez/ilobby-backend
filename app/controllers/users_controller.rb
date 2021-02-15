class UsersController < ApplicationController

  def create
    
    # let's make a user using the username and password from the params
    user = User.new(
      email: params[:email],
      password: params[:password],
    )
    
    if user.save
      token = encode_token(user.id)
      render json: {user: user, token: token}
    else
      render json: {errors: user.errors.full_messages}
    end
  end

  def show
    byebug
    token = request.headers['Authorization']
    puts 'FirebaseIdToken::Signature.verify(token)'
    puts FirebaseIdToken::Signature.verify(token)
    byebug

    if session_user
      render json: session_user, serializer: UserSerializer
    else 
      render json: {errors: "No Authorization" }, status: 403
    end
  end

end
