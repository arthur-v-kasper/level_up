class PublicController < ApplicationController

  def index
    render json: { message: "I'm alive as public controller"}
  end
end
