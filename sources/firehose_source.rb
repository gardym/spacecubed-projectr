require 'json'
require 'mongo'
require 'em-twitter'
require 'chronic'

module Tweaming
  class FirehoseSource
    def initialize(db, twitter_options)
      @collection_tweets = db.collection('tweets')
      @collection_events = db.collection('events')

      @client = EM::Twitter::Client.connect(twitter_options)
      @client.each { |result| handle(result) }
    end

    def handle(result)
      return unless result['text']

      tweet = JSON.parse(result)
      tweet["created_at"] = Chronic.parse(tweet["created_at"])

      puts "-- Twitter -- #{tweet["text"]}"

      @collection_events.insert(map_tweet_to_event tweet)
      @collection_tweets.insert(tweet)
    end

    def map_tweet_to_event(tweet)
      {
        :provider => 'Twitter',
        :username => tweet["user"]["screen_name"],
        :name => tweet["user"]["name"],
        :profile_image => tweet["user"]["profile_image_url"],
        :text => tweet["text"],
        :at => tweet["created_at"],
        :coordinates => tweet["coordinates"] ? { #tweet["coordinates"],
          :lat => tweet["coordinates"]["coordinates"][1],
          :lng => tweet["coordinates"]["coordinates"][0],
        } : nil,
        :place => tweet["place"]
      }
    end
  end
end
