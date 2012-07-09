require 'instagram'
require 'mongo'

module Tweaming
  class InstagramSource
    def initialize(db)
      @collection_grams = db.collection('grams')
      @collection_events = db.collection('events')
      @min_timestamp = time_now
    end

    def time_now
      Time.new.utc.to_i - (30 * 60) # Assume 'now' is half an hour ago - Instagram timeliness has its issues
    end

    def poll
      @max_timestamp = time_now
      puts "-- Instagr -- Searching for 'grams... (from #{@min_timestamp} to #{@max_timestamp})"
      begin
        grams = Instagram.media_search(ENV['LAT'], ENV['LNG'],
                                       :min_timestamp => @min_timestamp,
                                       :max_timestamp => @max_timestamp,
                                       :distance => 5000) # 5kms - the max Instagram radius
      rescue Instagram::BadRequest => e
        puts "-- ERROR: Instagram: #{e.message}"
      end
      @min_timestamp = @max_timestamp
      puts "-- Instagr -- Done, paused."

      if grams["data"] # otherwise we don't have any 'grams for this period
        grams["data"].each do |gram|
          # Despite slicing a time period, we are still drawing duplicates from the API
          # Only store this 'gram if we don't have it already
          exists_cursor = @collection_grams.find({:id => gram["id"]})
          exists_cursor.defer_as_a.callback do |grams|
            unless grams.count > 0
              puts "-- Instagr -- #{gram["link"]}"
              @collection_events.insert(map_gram_to_event gram)
              @collection_grams.insert(gram)
            end
          end
        end
      else
        puts grams
      end
    end

    def map_gram_to_event(gram)
      {
        :provider => 'Instagram',
        :username => gram["user"]["username"],
        :name => gram["user"]["full_name"],
        :profile_image => gram["user"]["profile_picture"],
        :text => gram["link"],
        :image => gram["images"]["standard_resolution"]["url"],
        :at => Time.at(gram["created_time"].to_i),
        :coordinates => {
          :lat => gram["location"]["latitude"],
          :lng => gram["location"]["longitude"]
        },
        :place => gram["location"]["name"],
        :recorded_at => Time.now
      }
    end
  end
end
