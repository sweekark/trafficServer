require 'rubygems'
require 'mongo'
require 'json'
include Mongo

@client = MongoClient.new('localhost', 27017)
@db     = @client['traffic']
@coll   = @db['uploader']
@normalizer = @db['normalizer']
@normalizer.remove

## get the latest endpoints from uploader
puts "new entries updated into uploader  {@coll.count()}"
puts @coll.count()
count = 0
@coll.find({"update"=>0}).each { 
  |endPoint|
  puts count 
  ## on each of these endpoints get the previous entry for the same uvid 
  ## this will be the start point
  startPoint = @coll.find_one(
    {"uvid" => endPoint["uvid"],
      "junctionId"=> {"$ne" => endPoint["junctionId"]}}
  )
  timeDiff = endPoint["timestamp"] - startPoint["timestamp"]

  ## if the entry for the uvid is not present in normalizer create new
  if (@normalizer.find(:from=>startPoint["junctionId"],:to => endPoint["junctionId"]).count == 0) then
    @normalizer.insert(:from=>startPoint["junctionId"],:to => endPoint["junctionId"],
                       :timeTaken => [{:value => timeDiff,:timestamp => endPoint["timestamp"] } ] )
  end

  ## if present just push the value to the array
  if (@normalizer.find(:from=>startPoint["junctionId"],:to => endPoint["junctionId"]).count != 0) then
    @normalizer.update(
      {:from=>startPoint["junctionId"],:to => endPoint["junctionId"]},
      {
      "$push" => {:timeTaken =>  [{:value => timeDiff,:timestamp => endPoint["timestamp"] } ] 
    }
    })
  end
  count = count +1
}
