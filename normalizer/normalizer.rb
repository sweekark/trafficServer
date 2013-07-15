require 'rubygems'
require 'mongo'
require 'json'
include Mongo
require_relative 'PopulateNormalizer'

@client = MongoClient.new('localhost', 27017)
@db     = @client['traffic2']
@coll   = @db['uploader']
@normalizer = @db['normalizers']
@junction = @db['junctions']


## get the latest endpoints from uploader
puts "new entries updated into uploader  #{@coll.count()}"
count = 0

@coll.find({"update"=>0}).each { 
  |endPoint|
  if count == 700
#    exit
  end
  ## on each of these endpoints get the previous 
  ## entry for the same uvid 
  ## this will be the start point
	#puts " checking data for uvid :: #{endPoint["uvId"]} " 
  startPoint = @coll.find_one(
    {"uvId" => endPoint["uvId"],
      "junctionId"=> {"$ne" => endPoint["junctionId"]},
      "timestamp"=> {"$lt" => endPoint["timestamp"]},
  }
  )
  if startPoint  then
    puts "##########################################################"
    puts "for uvid #{ endPoint["uvId"]}"
    puts "start point exits for end point #{endPoint["junctionId"]} in uploader db"
    puts "setting update to 1 for start point #{startPoint["junctionId"]} "
    @coll.update({"_id" => startPoint["_id"]},{"$set"=>{"update"=>1}})
    timeDiff = endPoint["timestamp"] - startPoint["timestamp"]
    PopulateNormalizer.new( startPoint,endPoint,timeDiff)
  end

  count = count +1
}
