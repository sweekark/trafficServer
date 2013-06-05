require 'rubygems'
require 'mongo'
require 'json'
include Mongo
require_relative 'PopulateNormalizer'

@client = MongoClient.new('localhost', 27017)
@db     = @client['traffic']
@coll   = @db['uploader']
@normalizer = @db['normalizers']
@junction = @db['junctions']


## get the latest endpoints from uploader
puts "new entries updated into uploader  #{@coll.count()}"
count = 0

@coll.find({"update"=>0}).each { 
  |endPoint|
  puts count 
  if count == 12
    exit
  end
  ## on each of these endpoints get the previous 
  ## entry for the same uvid 
  ## this will be the start point
  startPoint = @coll.find_one(
    {"uvid" => endPoint["uvid"],
      "junctionId"=> {"$ne" => endPoint["junctionId"]},
      "timestamp"=> {"$lt" => endPoint["timestamp"]},
  }
  )
  if startPoint  then
    puts "##########################################################"
    puts "start point exits for end point #{endPoint["junctionId"]} in uploader db"
    timeDiff = endPoint["timestamp"] - startPoint["timestamp"]
    PopulateNormalizer.new( startPoint,endPoint,timeDiff)
  end

  count = count +1
}
