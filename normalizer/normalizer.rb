require 'rubygems'
require 'mongo'
require 'json'
include Mongo

@client = MongoClient.new('localhost', 27017)
@db     = @client['traffic']
@coll   = @db['uploader']
@normalizer = @db['normalizer']
@normalizer.remove



=begin
  use the start point and end point from the uploader
  insert it into the normalizer
=end

def normalizer(startPoint,endPoint)
  timeDiff = endPoint["timestamp"] - startPoint["timestamp"]
  @timeTakenCount = 0
  @timeTakenLatest = 5
  if ( @normalizerEntry = @normalizer.find_one( 
                                               {:from=>startPoint["junctionId"],:to => endPoint["junctionId"]}
                                              ) ) then
                                              puts @normalizerEntry
                                              @timeTakenArray = @normalizerEntry["timeTaken"]
                                              @timeTakenCount =  @normalizerEntry["timeTaken"].count
                                              @timeTakenLatest =  @normalizerEntry["latest"]
  end
  ## if the entry for the uvid is not present in normalizer create new
  ## if present just push the value to the array 
  ## upsert => true option will handle this
  if @timeTakenCount < 5 then 
    @normalizer.update(
      {:from=>startPoint["junctionId"],:to => endPoint["junctionId"]},
      {
      "$push" => {:timeTaken =>  {:value => timeDiff,:timestamp => endPoint["timestamp"] }  
    },"$set" => {:latest =>@timeTakenLatest}},
      {
      :upsert => true
    })
  else
    @normalizer.update(
      {:from=>startPoint["junctionId"],:to => endPoint["junctionId"]},
      {"$set" => 
        {"timeTaken.#{@timeTakenLatest}" =>  {:value => timeDiff,:timestamp => endPoint["timestamp"] },
          "latest" => @timeTakenLatest}}
    )

  end
end

## get the latest endpoints from uploader
puts "new entries updated into uploader  #{@coll.count()}"
count = 0

@coll.find({"update"=>0}).each { 
  |endPoint|
  puts count 
  if count == 6 
    exit
  end
  ## on each of these endpoints get the previous entry for the same uvid 
  ## this will be the start point
  startPoint = @coll.find_one(
    {"uvid" => endPoint["uvid"],
      "junctionId"=> {"$ne" => endPoint["junctionId"]}}
  )
  normalizer(startPoint,endPoint)
  count = count +1
}


