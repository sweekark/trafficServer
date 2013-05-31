#######################################################
=begin
  use the start point and end point from the uploader
  insert it into the normalizer
  create a new entry
  insert time stamps into normaliser untill time taken mas
  update the time taken max array based on latest index
=end
######################################################
class PopulateNormalizer

  def updateTimeTaken(startPoint,endPoint,lastIndex,timeDiff)
     presentIndex = (@lastIndex + 1)% @timeTakenMax
      puts " updating time taken on index #{presentIndex}"
      @normalizerE = @normalizer.update(
        {:"from.junction.id"=>startPoint["junctionId"],:"to.junction.id" => endPoint["junctionId"]},
        {"$set" => 
          {"timeTaken.#{presentIndex}" =>  {:value => timeDiff,:timestamp => endPoint["timestamp"] },
            "presentIndex" => presentIndex }}
      )
  end

  def CreateNew(startPoint,endPoint,lastIndex,timeDiff)
     presentIndex = (@lastIndex + 1)% @timeTakenMax
    @normalizer.update(
      {:"from.junction"=>@junction.find_one(id:startPoint["junctionId"]),:"to.junction" => @junction.find_one(:id=>endPoint["junctionId"])},
      {
      "$push" => {:timeTaken =>  {:value => timeDiff,:timestamp => endPoint["timestamp"] }  
    },"$set" => {:presentIndex => presentIndex}},
      {
      :upsert => true
    })
  end

  def initialize(startPoint,endPoint,timeDiff)
    @client = MongoClient.new('localhost', 27017)
    @db     = @client['traffic']
    @coll   = @db['uploader']
    @normalizer = @db['normalizers']
    @junction = @db['junctions']
#@normalizer.remove


    ## control the no of time taken entried in the bucket
    ## this will be the latest entries
    @timeTakenMax = 3
    @timeTakenCount = 0
    @lastIndex = -1 # when no entry present for the start n end point
    if ( @normalizerEntry = @normalizer.find_one( 
                                                 {
      :"from.junction.id"=>startPoint["junctionId"],
      :"to.junction.id" => endPoint["junctionId"]
    } ) 
       ) then
       @timeTakenArray = @normalizerEntry["timeTaken"]
       @timeTakenCount =  @normalizerEntry["timeTaken"].count
       @lastIndex =  @normalizerEntry["presentIndex"]
       puts " entry exists for start point #{startPoint["junctionId"]} endpoint #{endPoint["junctionId"]} in nomralizer"
       puts "time taken count is #{@timeTakenCount}"
    end
    ## if the entry for the uvid is not present in normalizer create new
    ## if present just push the value to the array 
    ## upsert => true option will handle this
    #calculateNextBuffer()
    if @timeTakenCount < @timeTakenMax then 
      CreateNew(startPoint,endPoint,@lastIndex,timeDiff)
      puts " pushing new entry for time taken at index #{@timeTakenCount}"
    else
      updateTimeTaken(startPoint,endPoint,@lastIndex,timeDiff)
           puts "##########################################################"
    end
  end
end
