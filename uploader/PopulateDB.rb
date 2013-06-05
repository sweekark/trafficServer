require 'rubygems'
require 'mongo'
require 'json'
include Mongo

class PopulateDB
  def initialize()
  end

  def pushData(data)
    ########### sample data to test
    string = '{"trafficInfo" : [ { "junctionId" : "9:7:1","location":{"lon":12.95120,"lat":77.69977},"timestamp":1369758088,"uvid":"abcd"},{ "junctionId" : "92:7:1","location":{"lon":12.95508,"lat":77.68811},"timestamp":1369758194,"uvid":"abcd"} ] }'
    ##################################
    parsed = JSON.parse(string) # returns a hash
    array_of_hashes = []
    parsed["trafficInfo"].each do |trafficInfo|
      newPost = {
        :junctionId => trafficInfo["junctionId"],
        :uvId => trafficInfo["uvid"],
        :location => trafficInfo["location"],
        :timestamp => trafficInfo["timestamp"],
        :update => 0
      } 
      array_of_hashes << newPost
    end
    @client = MongoClient.new('localhost', 27017)
    @db     = @client['traffic']
    @coll   = @db['uploader']
    #@coll.remove

    @coll.insert(array_of_hashes)
  end
end
