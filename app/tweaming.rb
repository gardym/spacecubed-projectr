require 'json'
require 'em-mongo'
require 'sinatra/async'

require 'mongodb'

class AsyncTweaming < Sinatra::Base
  register Sinatra::Async

  attr_accessor :events_collection

  def initialize
    db = Tweaming::DB.connect
    @events_collection = db.collection('events')
    super
  end

  aget '/client' do
    body { erb :client }
  end

  aget '/events' do #?from=<unix timestamp>&to=<unix timestamp>
    from = Time.at(params[:from].to_i)
    to = Time.at(params[:to].to_i)

    events_query = {"recorded_at" => { "$gte" => from, "$lt" => to } }

    events_cursor = @events_collection.find(events_query)
    events_cursor.defer_as_a.callback do |events|
      body { JSON.pretty_generate(events) }
    end
  end
end
