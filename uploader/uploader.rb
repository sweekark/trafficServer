require 'rubygems'
require 'mongo'
require 'json'
include Mongo

string = '{"trafficInfo" : [ { "junctionId" : "9:7:1","location":{"long":"93","lat":"45"},"timestamp":45125125412},{ "junctionId" : "92:7:1","location":{"long":"93","lat":"45"},"timestamp":45125125412} ] }'
parsed = JSON.parse(string) # returns a hash

array_of_hashes = []
parsed["trafficInfo"].each do |trafficInfo|
	newPost = {:junctionId => trafficInfo["junctionId"],:location => trafficInfo["location"],:update => 0} 
array_of_hashes << newPost
end

@client = MongoClient.new('localhost', 27017)
@db     = @client['sample-db']
@coll   = @db['uploader']

  @coll.insert(array_of_hashes)
