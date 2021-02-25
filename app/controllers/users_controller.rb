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

  def index
    token = request.headers['Authorization']
    verified = FirebaseIdToken::Signature.verify(token)

    if verified
      # look up verified['user_id'] in db
      existing_user = User.find_by(user_id: verified['user_id'])
      if existing_user
        # if it exists, return the data using UserSerializer
        render json: existing_user, serializer: UserSerializer
      else
        # if it does not exist, create a user, then return data using UserSerializer
        new_user = User.create(user_id: verified['user_id'], email: verified['email'])
        render json: new_user, serializer: UserSerializer

      end
    else 
      #  if user is not verified return error, 403 status
      render json: {errors: "No Authorization" }, status: 403
    end
  end

end
