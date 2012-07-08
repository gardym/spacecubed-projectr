require 'json'
require 'em-mongo'
require 'sinatra/async'

class AsyncTweaming < Sinatra::Base
  register Sinatra::Async

  attr_accessor :events_collection

  def initialize
    db = EM::Mongo::Connection.new.db('tweaming')
    @events_collection = db.collection('events')
    super
  end

  aget '/client' do
    body { erb :client }
  end

  aget '/events' do #?from=<unix timestamp>&to=<unix timestamp>
    from = Time.at(params[:from].to_i)
    to = Time.at(params[:to].to_i)

    puts "Fetching events from #{from} to #{to}"

    events_query = {"at" => { "$gte" => from, "$lt" => to } }

    events_cursor = @events_collection.find(events_query)
    events_cursor.defer_as_a.callback do |events|
      body { JSON.pretty_generate(events) }
    end
  end
end
