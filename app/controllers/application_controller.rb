class ApplicationController < ActionController::API

      def current_user
            token = request.headers['Authorization']
            verified = FirebaseIdToken::Signature.verify(token)

            if verified
            # look up verified['user_id'] in db
                  existing_user = User.find_by(user_id: verified['user_id'])
                  if existing_user
                        return existing_user 
                  else
                        return User.create(user_id: verified['user_id'], email: verified['email'])
                  end
            else 
                  #  if user is not verified return error, 403 status
                  return nil
            end
      end

      def check_current_user
            unless current_user
                  render json: {errors: "No Authorization" }, status: 403
            end
      end

end
