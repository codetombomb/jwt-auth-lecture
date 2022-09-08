## Section 1 - Create Users

- [ ]  Create new Users in Rails
- [ ]  Explain how hashing works

## Section 2 - Authenticate Users

- [ ]  Verify Users’ identity
- [ ]  Issue signed tokens to Users

## Section 3 - Protect Resources

- [ ]  Verify tokens in Rails
- [ ]  Protect resources

## Creating Users - Build and Burn

1. Add the `bcrypt` gem and `bundle install`
2. Create route to create a User
    
    ```ruby
    Rails.application.routes.draw do
      resources :users, only: [:create]
    end
    ```
    
3. Create controller to create a User
    1. `rails g controller users`
    2. What’s the action I need to create? - CREATE
    
    ```ruby
    class UsersController < ApplicationController
      def create
    		# Read in user params
    		# Create a new user
    		# Send back the created user
      end
    end
    
    ```
    
4. Create a User model/migration with a secure password
    1. `rails g model user`
    
    ```ruby
    class CreateUsers < ActiveRecord::Migration[7.0]
      def change
        create_table :users do |t|
          t.string :username
          t.string :password_digest
    
          t.timestamps
        end
      end
    end
    ```
    
    - run migration
    - `has_secure_password` on User model
5. Add code to Create action

```ruby
class UsersController < ApplicationController
  def create
		# Read in user params
		# Create a new user
		user = User.create(
			name: params[:username],
			password: params[:password]
		)
		# Send back the created user
		render json: user, staus: :created
  end
end
```

1. Test in Postman

```json
{
   "username": "codetombomb",
   "password": "asdf123"
}
```

## Authenticate Users - JWT

1. Create a login route

```ruby

# routes.rb
post 'login', to: "authentication#login"
```

1. Create a login controller/action
    1. `rails g controller authentication`
    2. Look up User
    3. Authenticate User

```ruby
class AuthenticationController < ApplicationController
  def login
    user = User.find_by(username: params[:username])
		if !user
			render json: { error: "Invalid username" }, status: :unauthorized
		else
			if user.authenticate(params[:password])
				render json: { message: "Correct password" }
			else
				render json: { message: "Wrong password" }, status: :unauthorized
		else
		end
  end
end
```

***Student’s turn***

### With Tokens

1. `bundle add jwt`
2. If the login action - if a user is authenticated, we are going to use the `JWT.encode()` method to encode our User data and send it to the client.
    1. `JWT.encode()` takes in two args
        1. A hash - whatever data that we want to send to the client
        2. The application's secret password.
            1. This can be any string but rails provides one for us to use.
            2. `Rails.application.secrets.secret_key_base[0]`
3. Code:

```ruby
class AuthenticationController < ApplicationController
  def login
    user = User.find_by(username: params[:username])
    if !user
      render json: {errors: ["Username invaid"]}, status: :unauthorized
    else
      if user.authenticate(params[:password])
        secret_key = Rails.application.secrets.secret_key_base[0]
        token = JWT.encode({user_id: user.id, username: user.username}, secret_key)
        render json: {token: token}
      else
        render json: {errors: ["Password invalid"]}, status: :unauthorized
      end
    end
  end
end
```

1. Test with postman
    1. We get our encoded token back
    2. **Base 64 Encoding
    Base 10 Counting system
    Base 2 - Binary**
    - Referring to the density of information that we can store in each unit.
    - Binary - 1 or 0 - On or Off
    - Base 10 - numbers 0 - 9
        - We can store 10 different things in one character
    - Base 64
        - All uppercase letters
        - All lowercase letters
        - Numbers 0 - 9
        - Underscores - Dashes - slashes
        - We can do all of these things in one character
    1. This is encoded - not encrypted
        1. Encoding data is used only when talking about data that is not securely encoded.
    2. **JWT**
    - [https://jwt.io/](https://jwt.io/)

### **JWT Auth with Bcrypt**

## Protect Resources

- The idea here is that we do not want to create a pet unless we are logged in.
1. Create a `Pet` model and seed 
    1. `rails g model pet`
    2. `rails g controller pets`
    3. Add routes:
        
        ```ruby
        resources :pets, only: [:index, :create]
        ```
        
    4. Add Controller
        
        ```ruby
        	class PetsController < ApplicationController
            def index
                pets = Pet.all
                render json: pets
            end
        
            def create
                pet = Pet.create(pet_params)
                render json: pet, status: :created
            end
        
            private
        
            def pet_params
                params.permit(:name, :species)
            end
        end
        ```
        
        e. Create seeds
        
        ```ruby
        Pet.destroy_all
        
        Pet.create(
        	name: "Wednesday",
        	species: "Cat"
        )
        Pet.create(
        	name: "Fester",
        	species: "Dog"
        )
        ```
        
        f. `rails db:seed`
        g. Test endpoints in Postman
        
        - Get `/pets`
        - Post `/pets`
            
            ```json
            {
               "name": "Beignet",
               "species": "Cat"
            }
            ```
            
        
        ### Protect Resources
        
        - Check for presence of token
            - Through Authorization headers
            
            ```ruby
            
            class PetsController < ApplicationController
                def index
                    pets = Pet.all
                    render json: pets
                end
            
                def create
                    header = request.headers["Authorization"]
                    token = header.split(" ")[1]
            
                    if !token
                        # if no token, render error
                        render json: { error: "Must be logged in to do this!"}, status: :unauthorized
                    else
                        #else, decode the payload using our Rails signature. 
                        secret_key = Rails.application.secrets.secret_key_base
                        begin
                            # I would like for you to attempt to do this:
                            payload = JWT.decode(token, secret)[0]
                            pet = Pet.create(pet_params)
                            render json: pet, status: :created
                        rescue
                            render json: { error: "Must be logged in to do this!"}, status: :unauthorized               
                        end
                    end
            
                end
            ```
            
            1. Use the secret rails key to `decode` the payload. ***But, we can run into an issue here. This is how we can guard against things going wrong***
                1. Use ruby `Begin-Rescue-End` to try and decode
                2. If we run into a problem, render an error to the client.
            
            ```ruby
            secret_key = Rails.application.secrets.secret_key_base
            begin
                # I would like for you to attempt to do this:
                payload = JWT.decode(token, secret_key)[0]
                @user = User.find(payload["user_id"])
            rescue
                # you ran into an error - do this instead
                render json: { error: "Must be logged in to do this!"}, status: :unauthorized               
            end
            ```
            
        - Send POST from postman
            - USER NEEDS TO BE LOGGED IN HERE
                - Make sure to grab the token
                - Add token to authorization header in postman
                - Select type “Bearer Token”
                - Paste token in field
                
            

## Separation of Concerns

- Refactor out into Application controller
    - In the Application Controller:
    
    ```jsx
    class ApplicationController < ActionController::API
    
        def authenticate
            header = request.headers["Authorization"]
            token = header.split(" ")[1]
    
            if !token
                # if no token, render error
                render json: { error: "Must be logged in to do this!"}, status: :unauthorized
            else
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
    ```
    
    - In the Pets Controller:
    
    ```jsx
    class PetsController < ApplicationController
        before_action :authenticate, only: [:create]
        def index
            pets = Pet.all
            render json: pets
        end
    
        def create
            pet = Pet.create(pet_params)
            render json: pet, status: :created
        end
    
        private
    
        def pet_params
            params.permit(:name, :species)
        end
    end
    ```
    

## On the React side
```javascript
fetch("http://localhost:3000/login", {
  method: "POST",
  headers: {
    "Content-Type": "application/json"
  },)
	.then(r => r.json())
	.then(data => {
		const {token} = data

		localStorage.setItem("token", token)
	})


fetch("http://localhost:3000/pets", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "Authorization": `Bearer ${localStorage.getItem("token")}`
  },
  body: JSON.stringify(pet)
})
```
