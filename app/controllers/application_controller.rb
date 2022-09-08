class ApplicationController < ActionController::API
    private
    def authenticate
        header = request.headers["Authorization"]
        
        if header.nil?
            # if no token, render error
            render json: { error: "Must be logged in to do this!"}, status: :unauthorized
            else
            token = header.split(" ")[1]
            #else, decode the payload using our Rails signature. 
            secret_key = Rails.application.secrets.secret_key_base
            begin
                # I would like for you to attempt to do this:
                payload = JWT.decode(token, secret_key)[0]
                @user = User.find(payload["user_id"])
            rescue
                # you ran into an error - do this instead
                render json: { error: "Must be logged in to do this!"}, status: :unauthorized               
            end
        end
    end
end
