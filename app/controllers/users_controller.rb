class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def new
    @users = User.new
  end

  def create
    @recommended_careers = generate_career
    @users = User.new(description: params["description"], career: @recommended_careers)

    if @users.save
      redirect_to @users
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def rating
    @user = User.find(params[:id])
    recommended_careers = @user.career
    @array_careers = JSON.parse(recommended_careers)
    
  end

  def save_rating
    puts params
    @user = User.find(params[:id])
    careers = @user.career
    array_careers = JSON.parse(careers)

    array_careers.each do |career|
      choice = params["career_choice_#{career}"]

      # Save the rating to the database for the user and career
      # You can modify this code to suit your database structure
      if choice == career
        @user.ratings.create(career_name: career, like: true)
      elsif choice == "no_#{career}"
        @user.ratings.create(career_name: career, like: false)
      end
    end
    redirect_to user_path
  end

  private

    def generate_career
      client = OpenAI::Client.new(access_token: "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")
      
      num_words = 5
      lst_words = params["description"]
      prompt = "A person uses the following #{num_words} words for self-description: #{lst_words}, could you provide 10 potential careers that are suitable for the person?"
      response = client.chat(
        parameters: {
            model: "gpt-3.5-turbo",
            messages: [{ role: "user", content: prompt}],
            temperature: 0.7,
        })
      options = response['choices'][0]['message']['content'].scan(/\d+\.\s(.*?):/).flatten
      return options
    end
  end

