class AuthenticationController < ApplicationController
  def login
    # Find user through params[:username]
    user = User.find_by(username: params[:username])
    # If our user was not found - render error
    if !user
      render json: { message: "Username invalid"}, status: :unauthorized
    else
      # otherwise, check:
        # Is user authenticated with password? if so
        if user.authenticate(params[:password])
          signature = Rails.application.secrets.secret_key_base
          token = JWT.encode({user_id: user.id, username: user.username}, signature)

          # JWT.encode({user_id, username}, signature)
          # Render user
          render json: { token: token }
        else
        # Otherwise - render error
          render json: { message: "Password invalid"}, status: :unauthorized
        end
    end
  end
end
