module Pubsub
  class Subscriber
    def initialize(subscription_name)
      @pubsub = ::Google::Cloud::Pubsub.new
      @subscription = @pubsub.subscriber subscription_name
    end

    def listen
      raise "Subscription not found" unless @subscription

      subscriber = @subscription.listen do |message|
        PubsubMessageJob.perform_later(message.data, message.attributes)
        message.ack!
      end

      subscriber.start
    end
    
  end
end