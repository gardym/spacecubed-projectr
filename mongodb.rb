module Tweaming
  class DB
    def self.connect
      if ENV['MONGOLAB_URI']
        mongolab = URI.parse(ENV['MONGOLAB_URI'])
        cn = EM::Mongo::Connection.new(mongolab.host, mongolab.port)
        db = cn.db(mongolab.path.gsub(/^\//, ''))
        db.authenticate(mongolab.user, mongolab.password)
        db
      else
        EM::Mongo::Connection.new.db('tweaming')
      end
    end
  end
end
