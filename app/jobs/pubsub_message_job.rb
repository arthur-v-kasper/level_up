class PubsubMessageJob < ApplicationJob
  queue_as :default

  def perform(data, attributes = {})
    Rails.logger.info "📨 Message received from Pub/Sub"
    Rails.logger.info "Data: #{data}"
    Rails.logger.info "Attributes: #{attributes.inspect}"
  end
end