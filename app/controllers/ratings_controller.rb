class RatingsController < ApplicationController

    def index
        user = User.find(params[:user_id])
        recommended_careers = user.career
        @array_careers = JSON.parse(recommended_careers) # recommended_career => "['a', 'b', 'c']"; after parse => ['a', 'b', 'c']
    end

    def save_rating
        curr_user = User.find(params[:user_id])
        careers = curr_user.career
        array_careers = JSON.parse(careers)
    
        array_careers.each do |career|
            choice = params["career_choice_#{career}"]
    
            # Save the rating to the database for the user and career
            # You can modify this code to suit your database structure
            if choice == "like"
                curr_user.ratings.create(career_name: career, like: true)
            elsif choice == "dislike"
                curr_user.ratings.create(career_name: career, like: false)
            end
        end
        redirect_to user_path(curr_user.id)
    end
end
