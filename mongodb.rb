module Tweaming
  class DB
    def self.connect
      if ENV['MONGOLAB_URI']
        uri = ENV['MONGOLAB_URI']
        cn = EM::Mongo::Connection.from_uri(uri)
        cn.db(uri.path.gsub(/^\//, ''))
      else
        EM::Mongo::Connection.new.db('tweaming')
      end
    end
  end
end
