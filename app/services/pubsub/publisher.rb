module Pubsub
  class Publisher
    def initialize(topic_name)
      @pubsub = ::Google::Cloud::Pubsub.new
      @topic  = @pubsub.publisher topic_name
    end

    def publish(data, attributes = {})
      @topic.publish(data, attributes)
    end
  end
end
