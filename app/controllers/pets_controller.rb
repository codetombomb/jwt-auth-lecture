class PetsController < ApplicationController
    before_action :authenticate, only: [:create]
    
    def index
        pets = Pet.all
        render json: pets
    end


    def create 
        pet = Pet.create(pet_params)
        render json: pet
    end

    private 

    def pet_params
        params.permit(:name, :species)
    end
end
