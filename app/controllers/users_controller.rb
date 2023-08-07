# skx
# increase scalability, taking advantage of bg jobs, mutate the state of the table(loading), separate api response 
# articles
# version

class UsersController < ApplicationController
  def index
    # n + 1 query, User model has associations with other models
    # qs: but I dint use user.rating on the relavent page
    # @users = User.all
    @users = User.includes(:ratings)
  end

  # def new
    # don't know why it can still render new.html.erb

    # possible reason:
    # Dynamic method generation: 
      # Rails has a concept called "method missing," where it dynamically generates methods based on the names of routes.
      # In this case, when you call new_user_path, 
      # Rails generates a method to handle that route even if it doesn't exist explicitly in your controller.
  # end

  def create
    user_description = params["description"]
    recommended_careers = generate_career(user_description) #change
    new_user = User.new(description: user_description, career: recommended_careers) #change

    if new_user.save
      # Rails will automatically generate a URL based on the user object's model and id
      # e.g., redirect_to new_user will redirect to the URL /users/:id
      redirect_to new_user
    else
      @error_message = new_user.errors.full_messages
      render :error, status: :unprocessable_entity
    end
  end

  def show
    @user = User.find(params[:id])
  end

  private

    def generate_career(words)
      # how many calls
      # multiple keys
      # master.key to git ignore

      # changes:
      # in rails console, used EDITOR=vim rails credentials:edit to add api key to config/credentials.yml.enc. <-- this file is decrypted by the key stored in master.key file
      # once added, Rails.application.credentials will output all the credentials saved in config/credentials.yml.enc
      chatgpt_api_access_token = Rails.application.credentials[:chatgpt_api_access_token]
      client = OpenAI::Client.new(access_token: chatgpt_api_access_token)
      
      num_words = 5
      lst_words = words
      prompt = "A person uses the following #{num_words} words for self-description: #{lst_words}, could you provide 10 potential careers that are suitable for the person?"
      response = client.chat(
        parameters: {
            model: "gpt-3.5-turbo",
            messages: [{ role: "user", content: prompt}],
            temperature: 0.7,
        })

      # This link shows the structure of response: https://platform.openai.com/docs/api-reference/making-requests
      # {
      #   "id":"chatcmpl-abc123",
      #   "object":"chat.completion",
      #   "created":1677858242,
      #   "model":"gpt-3.5-turbo-0301",
      #   "usage":{
      #       "prompt_tokens":13,
      #       "completion_tokens":7,
      #       "total_tokens":20
      #   },
      #   "choices":[
      #       {
      #         "message":{
      #             "role":"assistant",
      #             "content":"\n\nThis is a test!"
      #         },
      #         "finish_reason":"stop",
      #         "index":0
      #       }
      #   ]
      # }
      options = response['choices'][0]['message']['content'].scan(/\d+\.\s(.*?):/).flatten
      # this regex will match text follow this pattern but only the capture group () will be extracted.
      # part of the response:
          # Based on the self-description words provided ("friendly," "relaxing," "joyful," "good," "nice"), here are ten potential careers that might suit this person:
          # 1. Hospitality Manager: They can create a friendly and welcoming environment for guests, ensuring their comfort and satisfaction.
          # 2. Yoga Instructor: They can help people relax and find joy through yoga practice, promoting a healthy and peaceful lifestyle.
          # 3. Event Planner: They can organize and manage events, creating joyful and memorable experiences for attendees.
          # 4. Customer Service Representative: They can provide friendly and helpful assistance to customers, resolving their concerns and ensuring their satisfaction.
      return options
    end
  end

