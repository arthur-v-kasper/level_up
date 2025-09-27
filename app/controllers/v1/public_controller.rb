class V1::PublicController < ApplicationController
  def index
    Pubsub::Publisher.new("my-topic").publish(
      { user_id: 123, action: "created" }.to_json,
      event_type: "user_created"
    )


    render json: { message: "Topic published"} 
  end

end
