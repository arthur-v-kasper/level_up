require "google/cloud/pubsub"

Google::Cloud::Pubsub.configure do |config|
  config.project_id  = ENV["GCP_PROJECT_ID"]
  config.credentials = ENV["GOOGLE_APPLICATION_CREDENTIALS"]
end
