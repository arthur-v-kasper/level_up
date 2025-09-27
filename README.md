# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


```ruby
# Run job of subscribed 

docker compose exec app rails runner 'Pubsub::Subscriber.new("my-topic-sub").listen'
```