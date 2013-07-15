require 'rubygems'
require 'mongo'
require 'json'
include Mongo

class PopulateDB
  def initialize()
  end

  def pushData(data)
    parsed = JSON.parse(data) # returns a hash
    array_of_hashes = []
    parsed["trafficInfo"].each do |trafficInfo|
      newPost = {
        :junctionId => trafficInfo["junctionid"],
        :uvId => trafficInfo["uvid"],
        :location => trafficInfo["location"],
        :timestamp => trafficInfo["timestamp"],
        :update => 0
      } 
      array_of_hashes << newPost
    end
    @client = MongoClient.new('localhost', 27017)
    @db     = @client['traffic2']
    @coll   = @db['uploader']
    #@coll.remove

    @coll.insert(array_of_hashes)
  end
end
