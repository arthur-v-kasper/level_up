class LoggedController < ApplicationController
   def index
    render json: { message: "I'm alive as logged controller"}
  end
end
