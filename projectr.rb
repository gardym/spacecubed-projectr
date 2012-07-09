require 'em-synchrony'
require 'em-mongo'

require 'sources/firehose_source'
require 'sources/instagram_source'
require 'mongodb'
include Tweaming

require 'app/tweaming'

# Instagram...obv.
Instagram.configure do |c|
  c.client_id = ENV['INSTAGRAM_CLIENT_ID']
  c.adapter = :em_synchrony
end

# Twitter streaming API (aka Firehose)
# Use basic auth with any Twitter account if you don't want to OAuth
#:basic => {
#  :username => ENV['FIREHOSE_BASIC_USERNAME'],
#  :password => ENV['FIREHOSE_BASIC_PASSWORD']
#}

firehose_term_options = {
  :path => '/1/statuses/filter.json',
  :oauth => {
    :consumer_key => ENV['FIREHOSE_OAUTH_CONS_KEY'],
    :consumer_secret => ENV['FIREHOSE_OAUTH_CONS_SEC'],
    :token => ENV['FIREHOSE_OAUTH_TOKEN'],
    :token_secret => ENV['FIREHOSE_OAUTH_TOKEN_SEC']
  },
  :params => { :track => ENV['FIREHOSE_TERMS'] },
}

user_stream_options = {
  :host => 'userstream.twitter.com', :path => '/2/user.json',
  :oauth => {
    :consumer_key => ENV['FIREHOSE_OAUTH_CONS_KEY'],
    :consumer_secret => ENV['FIREHOSE_OAUTH_CONS_SEC'],
    :token => ENV['FIREHOSE_OAUTH_TOKEN'],
    :token_secret => ENV['FIREHOSE_OAUTH_TOKEN_SEC']
  },
  :params => { :with => 'followings' }
}

# Reactor starts here.
EM.synchrony do
  db = DB.connect
  Rack::Handler::Thin.run AsyncTweaming.new, :Port => ENV['PORT']

  FirehoseSource.new(db, firehose_term_options)
  FirehoseSource.new(db, user_stream_options)

  instagram = InstagramSource.new(db)
  EM::Synchrony.add_periodic_timer(30) { instagram.poll }
  instagram.poll
end
