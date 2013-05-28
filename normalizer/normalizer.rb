require 'rubygems'
require 'mongo'
require 'json'
include Mongo

@client = MongoClient.new('localhost', 27017)
@db     = @client['traffic']
@coll   = @db['uploader']
@normalizer = @db['normalizers']
@junction = @db['junctions']
@normalizer.remove



=begin
  use the start point and end point from the uploader
  insert it into the normalizer
=end

def normalizer(startPoint,endPoint)
  timeDiff = endPoint["timestamp"] - startPoint["timestamp"]
  @timeTakenCount = 0
  @timeTakenLatest = 0
  if ( @normalizerEntry = @normalizer.find_one( 
                                               {
    :"from.junction.id"=>startPoint["junctionId"],
    :"to.junction.id" => endPoint["junctionId"]
  } ) 
     ) then
     puts @normalizerEntry
     @timeTakenArray = @normalizerEntry["timeTaken"]
     @timeTakenCount =  @normalizerEntry["timeTaken"].count
     @timeTakenLatest =  @normalizerEntry["latest"]
  puts " in check cond time taken count is #{@timeTakenCount}"
  end
  ## if the entry for the uvid is not present in normalizer create new
  ## if present just push the value to the array 
  ## upsert => true option will handle this
  #calculateNextBuffer()
  puts "time taken count is #{@timeTakenCount}"
  if @timeTakenCount < 2 then 
    @normalizer.update(
      {:"from.junction"=>@junction.find_one(id:startPoint["junctionId"]),:"to.junction" => @junction.find_one(:id=>endPoint["junctionId"])},
      {
      "$push" => {:timeTaken =>  {:value => timeDiff,:timestamp => endPoint["timestamp"] }  
    },"$set" => {:latest =>@timeTakenLatest}},
      {
      :upsert => true
    })
  else
    puts "in else #{@timeTakenLatest}"
    @timeTakenUpdate = (@timeTakenLatest + 1)%2
    @normalizer.update(
      {:"from.junction.id"=>startPoint["junctionId"],:"to.junction.id" => endPoint["junctionId"]},
      {"$set" => 
        {"timeTaken.#{@timeTakenLatest}" =>  {:value => timeDiff,:timestamp => endPoint["timestamp"] },
          "latest" => @timeTakenUpdate }}
    )
    puts "in else update #{@timeTakenUpdate}"

  end
end

## get the latest endpoints from uploader
puts "new entries updated into uploader  #{@coll.count()}"
count = 0

@coll.find({"update"=>0}).each { 
  |endPoint|
  puts count 
  if count == 12
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


